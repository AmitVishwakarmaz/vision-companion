import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:vision_companion/features/detector/constants/coco_labels.dart';
import 'package:vision_companion/features/detector/models/detection.dart';

void main() {
  group('Detection Model', () {
    test('computes confidence percentage correctly', () {
      const detection1 = Detection(
        label: 'person',
        classId: 0,
        confidence: 0.942,
        boundingBox: Rect.fromLTRB(0.1, 0.2, 0.5, 0.8),
      );

      expect(detection1.confidencePercentage, equals(94));
      expect(detection1.displayText, equals('person 94%'));

      const detection2 = Detection(
        label: 'cup',
        classId: 41,
        confidence: 0.057,
        boundingBox: Rect.fromLTRB(0.0, 0.0, 1.0, 1.0),
      );

      expect(detection2.confidencePercentage, equals(6));
      expect(detection2.displayText, equals('cup 6%'));
    });

    test('serializes to and from map accurately', () {
      const original = Detection(
        label: 'bottle',
        classId: 39,
        confidence: 0.88,
        boundingBox: Rect.fromLTRB(0.15, 0.25, 0.65, 0.75),
      );

      final map = original.toMap();
      expect(map['label'], equals('bottle'));
      expect(map['classId'], equals(39));
      expect(map['confidence'], equals(0.88));
      expect(map['confidencePercentage'], equals(88));

      final restored = Detection.fromMap(map);
      expect(restored, equals(original));
      expect(restored.boundingBox.left, equals(0.15));
      expect(restored.boundingBox.top, equals(0.25));
    });

    test('CocoLabels resolves standard 80 classes properly', () {
      expect(CocoLabels.labels.length, equals(80));
      expect(CocoLabels.getLabel(0), equals('person'));
      expect(CocoLabels.getLabel(1), equals('bicycle'));
      expect(CocoLabels.getLabel(79), equals('toothbrush'));
      // 1-indexed fallback
      expect(CocoLabels.getLabel(80), equals('toothbrush'));
      // Out of bounds fallback
      expect(CocoLabels.getLabel(999), equals('Object'));
    });
  });
}
