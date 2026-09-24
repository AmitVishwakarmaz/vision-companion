import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:vision_companion/features/detector/constants/coco_labels.dart';
import 'package:vision_companion/features/detector/models/detection.dart';

/// Raw frame data extracted from [CameraImage] to pass safely across isolates.
class FrameData {
  final Uint8List yPlane;
  final Uint8List? uPlane;
  final Uint8List? vPlane;
  final int width;
  final int height;
  final int yRowStride;
  final int uvRowStride;
  final int uvPixelStride;
  final int sensorOrientation;

  const FrameData({
    required this.yPlane,
    this.uPlane,
    this.vPlane,
    required this.width,
    required this.height,
    required this.yRowStride,
    required this.uvRowStride,
    required this.uvPixelStride,
    this.sensorOrientation = 90,
  });
}

/// Initialization message sent to the background isolate.
class _IsolateInitMessage {
  final SendPort sendPort;
  final Uint8List modelBytes;

  const _IsolateInitMessage({
    required this.sendPort,
    required this.modelBytes,
  });
}

/// Commands sent to the background isolate.
class _InferenceCommand {
  final FrameData frame;
  final double confidenceThreshold;

  const _InferenceCommand({
    required this.frame,
    this.confidenceThreshold = 0.50,
  });
}

/// Results returned from the background isolate.
class InferenceResult {
  final List<Detection> detections;
  final int inferenceTimeMs;

  const InferenceResult({
    required this.detections,
    required this.inferenceTimeMs,
  });
}

/// Manages background Dart Isolate execution for SSD MobileNet inference.
class TFLiteDetectorIsolate {
  Isolate? _isolate;
  SendPort? _sendPort;
  ReceivePort? _receivePort;
  Completer<InferenceResult>? _activeCompleter;
  bool _isInitialized = false;
  bool _isProcessing = false;

  bool get isInitialized => _isInitialized;
  bool get isProcessing => _isProcessing;

  /// Spawns the background isolate and loads the TFLite interpreter from [modelBytes].
  Future<void> initialize(Uint8List modelBytes) async {
    if (_isInitialized) return;

    final initCompleter = Completer<SendPort>();
    _receivePort = ReceivePort();

    _receivePort!.listen((message) {
      if (message is SendPort) {
        initCompleter.complete(message);
      } else if (message is Map<String, dynamic>) {
        final rawDetections = (message['detections'] as List<dynamic>? ?? [])
            .map((item) => Detection.fromMap(Map<String, dynamic>.from(item as Map)))
            .toList();
        final duration = (message['durationMs'] as num?)?.toInt() ?? 0;

        _isProcessing = false;
        _activeCompleter?.complete(
          InferenceResult(
            detections: rawDetections,
            inferenceTimeMs: duration,
          ),
        );
        _activeCompleter = null;
      }
    });

    try {
      _isolate = await Isolate.spawn(
        _isolateEntryPoint,
        _IsolateInitMessage(
          sendPort: _receivePort!.sendPort,
          modelBytes: modelBytes,
        ),
      );

      _sendPort = await initCompleter.future;
      _isInitialized = true;
    } catch (e) {
      debugPrint('TFLiteDetectorIsolate init error: $e');
      dispose();
      rethrow;
    }
  }

  /// Sends a camera frame to the background isolate for processing.
  /// Returns null if the isolate is still busy processing a previous frame (skips frame to ensure <150ms latency).
  Future<InferenceResult?> processFrame(
    FrameData frame, {
    double confidenceThreshold = 0.45,
  }) async {
    if (!_isInitialized || _sendPort == null || _isProcessing) {
      return null;
    }

    _isProcessing = true;
    _activeCompleter = Completer<InferenceResult>();

    _sendPort!.send(_InferenceCommand(
      frame: frame,
      confidenceThreshold: confidenceThreshold,
    ));

    return _activeCompleter!.future;
  }

  /// Shuts down the background isolate.
  void dispose() {
    _isInitialized = false;
    _isProcessing = false;
    _activeCompleter?.complete(const InferenceResult(detections: [], inferenceTimeMs: 0));
    _activeCompleter = null;
    _receivePort?.close();
    _receivePort = null;
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _sendPort = null;
  }

  /// The entry point for the spawned isolate.
  static void _isolateEntryPoint(_IsolateInitMessage initMessage) {
    final isolateReceivePort = ReceivePort();
    initMessage.sendPort.send(isolateReceivePort.sendPort);

    Interpreter? interpreter;
    try {
      final options = InterpreterOptions()..threads = 2;
      interpreter = Interpreter.fromBuffer(initMessage.modelBytes, options: options);
      interpreter.allocateTensors();
    } catch (e) {
      debugPrint('Isolate failed to load model buffer: $e');
      return;
    }

    // Input dimensions for SSD MobileNet V1: [1, 300, 300, 3] uint8
    const inputSize = 300;
    final inputBuffer = Uint8List(inputSize * inputSize * 3);

    isolateReceivePort.listen((message) {
      if (message is _InferenceCommand && interpreter != null) {
        final stopwatch = Stopwatch()..start();
        final frame = message.frame;

        // 1. Direct bilinear/nearest-neighbor downsample from YUV420 to [300, 300, 3] uint8
        _convertYUV420ToRgb300(frame, inputBuffer, inputSize);

        // 2. Prepare 4 outputs for standard SSD MobileNet
        // Output 0: Locations [1, 10, 4] (ymin, xmin, ymax, xmax)
        final outputLocations = List.generate(1, (_) => List.generate(10, (_) => List.filled(4, 0.0)));
        // Output 1: Classes [1, 10]
        final outputClasses = List.generate(1, (_) => List.filled(10, 0.0));
        // Output 2: Scores [1, 10]
        final outputScores = List.generate(1, (_) => List.filled(10, 0.0));
        // Output 3: Number of detections [1]
        final outputCount = List.filled(1, 0.0);

        final outputs = {
          0: outputLocations,
          1: outputClasses,
          2: outputScores,
          3: outputCount,
        };

        // 3. Run inference
        // Input shaped as [1, 300, 300, 3]
        final inputTensor = inputBuffer.reshape([1, inputSize, inputSize, 3]);
        interpreter.runForMultipleInputs([inputTensor], outputs);
        stopwatch.stop();

        final rawCount = outputCount[0].clamp(0, 10).toInt();
        final detectionsList = <Map<String, dynamic>>[];

        for (int i = 0; i < rawCount; i++) {
          final score = outputScores[0][i];
          if (score >= message.confidenceThreshold) {
            final classId = outputClasses[0][i].toInt();
            final label = CocoLabels.getLabel(classId);

            final ymin = (outputLocations[0][i][0] as num).toDouble().clamp(0.0, 1.0);
            final xmin = (outputLocations[0][i][1] as num).toDouble().clamp(0.0, 1.0);
            final ymax = (outputLocations[0][i][2] as num).toDouble().clamp(0.0, 1.0);
            final xmax = (outputLocations[0][i][3] as num).toDouble().clamp(0.0, 1.0);

            // Bounding box in normalized coordinates (left, top, right, bottom)
            final detection = Detection(
              label: label,
              classId: classId,
              confidence: score,
              boundingBox: Rect.fromLTRB(xmin, ymin, xmax, ymax),
            );
            detectionsList.add(detection.toMap());
          }
        }

        initMessage.sendPort.send({
          'detections': detectionsList,
          'durationMs': stopwatch.elapsedMilliseconds,
        });
      }
    });
  }

  /// Fast subsampling from YUV420 to RGB [300 x 300 x 3] with orientation handling.
  static void _convertYUV420ToRgb300(FrameData frame, Uint8List outRgb, int targetSize) {
    final yPlane = frame.yPlane;
    final uPlane = frame.uPlane;
    final vPlane = frame.vPlane;

    final srcWidth = frame.width;
    final srcHeight = frame.height;
    final yRowStride = frame.yRowStride;
    final uvRowStride = frame.uvRowStride;
    final uvPixelStride = frame.uvPixelStride;
    final orientation = frame.sensorOrientation;

    final hasUV = uPlane != null && vPlane != null;

    int outIndex = 0;
    for (int y = 0; y < targetSize; y++) {
      for (int x = 0; x < targetSize; x++) {
        int srcX;
        int srcY;

        if (orientation == 90) {
          srcX = (y * srcWidth) ~/ targetSize;
          srcY = ((targetSize - 1 - x) * srcHeight) ~/ targetSize;
        } else if (orientation == 270) {
          srcX = ((targetSize - 1 - y) * srcWidth) ~/ targetSize;
          srcY = (x * srcHeight) ~/ targetSize;
        } else {
          srcX = (x * srcWidth) ~/ targetSize;
          srcY = (y * srcHeight) ~/ targetSize;
        }

        srcX = srcX.clamp(0, srcWidth - 1);
        srcY = srcY.clamp(0, srcHeight - 1);

        final yOffset = srcY * yRowStride;
        final yVal = yPlane[yOffset + srcX];

        int r, g, b;
        if (hasUV) {
          final uvOffset = (srcY >> 1) * uvRowStride;
          final uvIndex = uvOffset + ((srcX >> 1) * uvPixelStride);
          final uVal = uPlane[uvIndex] - 128;
          final vVal = vPlane[uvIndex] - 128;

          r = (yVal + ((1436 * vVal) >> 10)).clamp(0, 255);
          g = (yVal - ((352 * uVal + 731 * vVal) >> 10)).clamp(0, 255);
          b = (yVal + ((1814 * uVal) >> 10)).clamp(0, 255);
        } else {
          r = yVal;
          g = yVal;
          b = yVal;
        }

        outRgb[outIndex++] = r;
        outRgb[outIndex++] = g;
        outRgb[outIndex++] = b;
      }
    }
  }
}
