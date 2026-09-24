import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vision_companion/core/services/analytics_service.dart';
import 'package:vision_companion/features/detector/models/detection.dart';
import 'package:vision_companion/features/detector/services/detector_service.dart';
import 'package:vision_companion/features/history/repositories/history_repository.dart';
import 'detector_state.dart';

class DetectorCubit extends Cubit<DetectorState> {
  final DetectorService? detectorService;
  final HistoryRepository? historyRepository;
  final AnalyticsService? analyticsService;

  bool _isProcessingFrame = false;
  DateTime? _lastHistoryLogTime;
  DateTime? _lastHapticTime;

  DetectorCubit({
    this.detectorService,
    this.historyRepository,
    this.analyticsService,
  }) : super(const DetectorInitial());

  /// Initializes the detector service, loads the TFLite model, and logs feature_opened.
  Future<void> initialize() async {
    try {
      analyticsService?.logFeatureOpened('live_object_detector');
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

  /// Pauses live detection.
  void pauseDetection() {
    if (state is DetectorResults) {
      emit(DetectorPaused(lastDetections: (state as DetectorResults).detections));
    } else {
      emit(const DetectorPaused());
    }
  }

  /// Resumes live detection from paused state.
  void resumeDetection() {
    emit(const DetectorRunning(detectedObjects: []));
  }

  /// Stops detection and resets state to Idle.
  void stopDetection() {
    emit(const DetectorStopped());
  }

  @override
  void emit(DetectorState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Feeds a camera frame from CameraController.startImageStream into the background isolate.
  Future<void> processCameraImage(
    CameraImage image, {
    int sensorOrientation = 90,
  }) async {
    if (isClosed || (state is! DetectorRunning && state is! DetectorResults)) {
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

      if (isClosed) return;

      if (result != null && (state is DetectorRunning || state is DetectorResults)) {
        emit(DetectorResults(
          detections: result.detections,
          inferenceTimeMs: result.inferenceTimeMs,
        ));

        // 1. Trigger haptic feedback when objects are detected
        if (result.detections.isNotEmpty) {
          _triggerHapticIfAppropriate();
        }

        // 2. Log detection_completed to Analytics
        analyticsService?.logDetectionCompleted(
          count: result.detections.length,
          categories: result.detections.map((d) => d.label).toSet().toList(),
          latencyMs: result.inferenceTimeMs,
        );

        // 3. Save detection results to Firestore history (throttled to avoid flooding)
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
      if (!isClosed) {
        emit(DetectorError('Inference error: $e'));
      }
    } finally {
      _isProcessingFrame = false;
    }
  }

  void _triggerHapticIfAppropriate() {
    final now = DateTime.now();
    if (_lastHapticTime == null || now.difference(_lastHapticTime!).inMilliseconds >= 700) {
      _lastHapticTime = now;
      try {
        HapticFeedback.lightImpact().catchError((_) {});
      } catch (_) {}
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
        _triggerHapticIfAppropriate();
        analyticsService?.logDetectionCompleted(
          count: objects.length,
          categories: objects,
        );

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
    _isProcessingFrame = false;
    detectorService?.dispose();
    return super.close();
  }
}
