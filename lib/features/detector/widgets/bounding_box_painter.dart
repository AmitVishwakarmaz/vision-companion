import 'package:flutter/material.dart';
import 'package:vision_companion/features/detector/constants/coco_labels.dart';
import 'package:vision_companion/features/detector/models/detection.dart';

/// CustomPainter that renders high-contrast bounding boxes, confidence percentages,
/// and color-coded boxes by object category over the camera preview.
class BoundingBoxPainter extends CustomPainter {
  final List<Detection> detections;
  final Size? previewSize;

  BoundingBoxPainter({
    required this.detections,
    this.previewSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (detections.isEmpty) return;

    for (final detection in detections) {
      final box = detection.boundingBox;

      // Scale normalized [0..1] coordinates to viewport canvas size
      final left = (box.left * size.width).clamp(0.0, size.width);
      final top = (box.top * size.height).clamp(0.0, size.height);
      final right = (box.right * size.width).clamp(0.0, size.width);
      final bottom = (box.bottom * size.height).clamp(0.0, size.height);

      final rect = Rect.fromLTRB(left, top, right, bottom);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));

      // Color-code box and label by object category
      final categoryColor = CocoLabels.getColorForCategory(detection.label);

      // 1. Subtle semi-transparent fill
      final fillPaint = Paint()
        ..color = categoryColor.withAlpha(30)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rrect, fillPaint);

      // 2. High-contrast double stroke:
      // Outer black stroke for contrast over light backgrounds
      final outerStroke = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;
      canvas.drawRRect(rrect, outerStroke);

      // Inner category color stroke
      final categoryStroke = Paint()
        ..color = categoryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawRRect(rrect, categoryStroke);

      // 3. Label text: Object category + confidence percentage, e.g. "PERSON 92%"
      final textSpan = TextSpan(
        text: ' ${detection.label.toUpperCase()} ${detection.confidencePercentage}% ',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final labelHeight = textPainter.height + 6;
      final labelWidth = textPainter.width + 8;

      double labelTop = top - labelHeight;
      if (labelTop < 0) {
        labelTop = top + 4;
      }
      final labelLeft = left.clamp(0.0, (size.width - labelWidth).clamp(0.0, size.width));

      final labelRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(labelLeft, labelTop, labelWidth, labelHeight),
        const Radius.circular(6),
      );

      // 4. Draw label badge background and black border
      final labelBgPaint = Paint()
        ..color = categoryColor
        ..style = PaintingStyle.fill;
      canvas.drawRRect(labelRect, labelBgPaint);

      final labelBorderPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawRRect(labelRect, labelBorderPaint);

      // 5. Draw text
      textPainter.paint(canvas, Offset(labelLeft + 4, labelTop + 3));
    }
  }

  @override
  bool shouldRepaint(covariant BoundingBoxPainter oldDelegate) {
    return oldDelegate.detections != detections || oldDelegate.previewSize != previewSize;
  }
}
