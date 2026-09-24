import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vision_companion/features/detector/services/tflite_detector_isolate.dart';

abstract class DetectorService {
  bool get isInitialized;
  Future<void> initialize({String modelPath = 'assets/models/2.tflite'});
  Future<InferenceResult?> processCameraImage(
    CameraImage image, {
    int sensorOrientation = 90,
    double confidenceThreshold = 0.50,
  });
  void dispose();
}

class LiveDetectorService implements DetectorService {
  final TFLiteDetectorIsolate _isolate;
  bool _initialized = false;
  bool _isProcessing = false;

  LiveDetectorService({TFLiteDetectorIsolate? isolate})
      : _isolate = isolate ?? TFLiteDetectorIsolate();

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize({String modelPath = 'assets/models/2.tflite'}) async {
    if (_initialized) return;

    try {
      final byteData = await rootBundle.load(modelPath);
      final modelBytes = byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );

      await _isolate.initialize(modelBytes);
      _initialized = true;
    } catch (e) {
      debugPrint('LiveDetectorService model load error: $e');
      rethrow;
    }
  }

  @override
  Future<InferenceResult?> processCameraImage(
    CameraImage image, {
    int sensorOrientation = 90,
    double confidenceThreshold = 0.50,
  }) async {
    if (!_initialized || _isProcessing) {
      return null; // Skip frame to keep frame rate high and latency under 150ms
    }

    _isProcessing = true;
    try {
      final planes = image.planes;
      if (planes.isEmpty) {
        _isProcessing = false;
        return null;
      }

      final yPlane = planes[0].bytes;
      final uPlane = planes.length > 1 ? planes[1].bytes : null;
      final vPlane = planes.length > 2 ? planes[2].bytes : null;

      final yRowStride = planes[0].bytesPerRow;
      final uvRowStride = planes.length > 1 ? (planes[1].bytesPerRow) : yRowStride;
      final uvPixelStride = planes.length > 1 ? (planes[1].bytesPerPixel ?? 1) : 1;

      final frameData = FrameData(
        yPlane: yPlane,
        uPlane: uPlane,
        vPlane: vPlane,
        width: image.width,
        height: image.height,
        yRowStride: yRowStride,
        uvRowStride: uvRowStride,
        uvPixelStride: uvPixelStride,
        sensorOrientation: sensorOrientation,
      );

      final result = await _isolate.processFrame(
        frameData,
        confidenceThreshold: confidenceThreshold,
      );

      return result;
    } finally {
      _isProcessing = false;
    }
  }

  @override
  void dispose() {
    _initialized = false;
    _isProcessing = false;
    _isolate.dispose();
  }
}
