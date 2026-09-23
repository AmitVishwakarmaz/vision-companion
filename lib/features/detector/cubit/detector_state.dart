import 'package:equatable/equatable.dart';
import 'package:vision_companion/features/detector/models/detection.dart';

abstract class DetectorState extends Equatable {
  const DetectorState();

  @override
  List<Object?> get props => [];
}

/// Idle state when the object detector is not running.
class DetectorInitial extends DetectorState {
  const DetectorInitial();
}

/// Alias for DetectorInitial to match 'Idle' requirement.
typedef DetectorIdle = DetectorInitial;

/// Running state when camera frames are being streamed.
class DetectorRunning extends DetectorState {
  final List<String> detectedObjects;

  const DetectorRunning({this.detectedObjects = const []});

  @override
  List<Object?> get props => [detectedObjects];
}

/// Results state carrying detected bounding boxes, confidence, categories, and latency.
class DetectorResults extends DetectorState {
  final List<Detection> detections;
  final int inferenceTimeMs;

  const DetectorResults({
    required this.detections,
    this.inferenceTimeMs = 0,
  });

  /// Convenience getter for simple list of detected category names.
  List<String> get detectedObjects => detections.map((d) => d.label).toList();

  @override
  List<Object?> get props => [detections, inferenceTimeMs];
}

/// Error state when camera initialization or inference fails.
class DetectorError extends DetectorState {
  final String message;

  const DetectorError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Stopped state (alias for stopped detection).
class DetectorStopped extends DetectorInitial {
  const DetectorStopped();
}
