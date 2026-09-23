import 'dart:ui';
import 'package:equatable/equatable.dart';

/// Represents an individual object detected in a frame.
class Detection extends Equatable {
  /// The human-readable category name of the detected object (e.g. "person", "cup").
  final String label;

  /// The COCO class identifier.
  final int classId;

  /// The model confidence score ranging from 0.0 to 1.0.
  final double confidence;

  /// Normalized bounding box coordinates within [0.0, 1.0] range (left, top, right, bottom).
  final Rect boundingBox;

  const Detection({
    required this.label,
    required this.classId,
    required this.confidence,
    required this.boundingBox,
  });

  /// The confidence score formatted as an integer percentage (0–100%).
  int get confidencePercentage => (confidence * 100).clamp(0, 100).round();

  /// User-friendly label with confidence percentage, e.g. "person 92%".
  String get displayText => '$label $confidencePercentage%';

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'classId': classId,
      'confidence': confidence,
      'confidencePercentage': confidencePercentage,
      'box': {
        'left': boundingBox.left,
        'top': boundingBox.top,
        'right': boundingBox.right,
        'bottom': boundingBox.bottom,
      },
    };
  }

  factory Detection.fromMap(Map<String, dynamic> map) {
    final boxMap = (map['box'] as Map<dynamic, dynamic>?) ?? {};
    return Detection(
      label: map['label'] as String? ?? 'Object',
      classId: map['classId'] as int? ?? 0,
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      boundingBox: Rect.fromLTRB(
        (boxMap['left'] as num?)?.toDouble() ?? 0.0,
        (boxMap['top'] as num?)?.toDouble() ?? 0.0,
        (boxMap['right'] as num?)?.toDouble() ?? 1.0,
        (boxMap['bottom'] as num?)?.toDouble() ?? 1.0,
      ),
    );
  }

  @override
  List<Object?> get props => [label, classId, confidence, boundingBox];
}
