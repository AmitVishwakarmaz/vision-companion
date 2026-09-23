import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vision_companion/features/detector/models/detection.dart';
import 'package:vision_companion/features/detector/services/detector_service.dart';
import 'package:vision_companion/features/history/repositories/history_repository.dart';
import 'detector_state.dart';

class DetectorCubit extends Cubit<DetectorState> {
  final DetectorService? detectorService;
  final HistoryRepository? historyRepository;
  bool _isProcessingFrame = false;
  DateTime? _lastHistoryLogTime;

  DetectorCubit({
    this.detectorService,
    this.historyRepository,
  }) : super(const DetectorInitial());

  /// Initializes the detector service and loads the TFLite model on the isolate.
  Future<void> initialize() async {
    try {
      if (detectorService != null && !detectorService!.isInitialized) {
        await detectorService!.initialize();
      }
    } catch (e) {
      emit(DetectorError('Failed to initialize TFLite model: $e'));
    }
  }

  /// Starts live detection stream.
  Future<void> startDetection({Map<String, dynamic>? metadata}) async {
    emit(const DetectorRunning(detectedObjects: []));
    try {
      await historyRepository?.logDetection(
        resultSummary: 'Live object detection session active: scanning for objects.',
        metadata: metadata ?? {
          'source': 'detector_camera',
          'status': 'running',
        },
      );
    } catch (_) {}
  }

  /// Stops detection and resets state to Idle.
  void stopDetection() {
    emit(const DetectorStopped());
  }

  /// Feeds a camera frame from CameraController.startImageStream into the background isolate.
  Future<void> processCameraImage(
    CameraImage image, {
    int sensorOrientation = 90,
  }) async {
    if (state is! DetectorRunning && state is! DetectorResults) {
      return;
    }

    if (_isProcessingFrame) {
      // Drop frame to ensure UI is never starved and inference latency stays < 150ms
      return;
    }

    _isProcessingFrame = true;
    try {
      final result = await detectorService?.processCameraImage(
        image,
        sensorOrientation: sensorOrientation,
      );

      if (result != null && (state is DetectorRunning || state is DetectorResults)) {
        emit(DetectorResults(
          detections: result.detections,
          inferenceTimeMs: result.inferenceTimeMs,
        ));

        // Periodically log to history repository when objects are detected (throttle to max once every 10s)
        if (result.detections.isNotEmpty && historyRepository != null) {
          final now = DateTime.now();
          if (_lastHistoryLogTime == null || now.difference(_lastHistoryLogTime!).inSeconds >= 10) {
            _lastHistoryLogTime = now;
            final detectedLabels = result.detections.map((d) => d.label).toSet().join(', ');
            historyRepository!.logDetection(
              resultSummary: 'Detected: $detectedLabels',
              metadata: {
                'source': 'detector_inference',
                'count': result.detections.length,
                'inferenceTimeMs': result.inferenceTimeMs,
              },
            ).catchError((_) => '');
          }
        }
      }
    } catch (e) {
      emit(DetectorError('Inference error: $e'));
    } finally {
      _isProcessingFrame = false;
    }
  }

  /// Direct method to update detected objects (retained for backward compatibility).
  Future<void> updateDetectedObjects(List<String> objects) async {
    if (state is DetectorRunning || state is DetectorResults) {
      final mockDetections = objects.asMap().entries.map((entry) {
        return Detection(
          label: entry.value,
          classId: entry.key,
          confidence: 0.90,
          boundingBox: const Rect.fromLTWH(0.1, 0.1, 0.8, 0.8),
        );
      }).toList();

      emit(DetectorResults(detections: mockDetections));
      if (objects.isNotEmpty) {
        try {
          await historyRepository?.logDetection(
            resultSummary: 'Detected: ${objects.join(', ')}',
            metadata: {
              'source': 'detector_inference',
              'objects': objects,
              'count': objects.length,
            },
          );
        } catch (_) {}
      }
    }
  }

  /// Logs a detection summary to Firestore history under users/{uid}/history/{docId}.
  Future<String?> logDetectionResult(String summary, {Map<String, dynamic>? metadata}) async {
    if (historyRepository == null) return null;
    return historyRepository!.logDetection(
      resultSummary: summary,
      metadata: metadata,
    );
  }

  @override
  Future<void> close() {
    detectorService?.dispose();
    return super.close();
  }
}
