import 'package:flutter/material.dart';
import 'package:vision_companion/features/detector/models/detection.dart';

/// CustomPainter that renders high-contrast bounding boxes, confidence percentages,
/// and object category labels over the camera preview.
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

    final boxPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final innerBoxPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final labelBgPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    for (final detection in detections) {
      final box = detection.boundingBox;

      // Scale normalized [0..1] coordinates to viewport canvas size
      final left = (box.left * size.width).clamp(0.0, size.width);
      final top = (box.top * size.height).clamp(0.0, size.height);
      final right = (box.right * size.width).clamp(0.0, size.width);
      final bottom = (box.bottom * size.height).clamp(0.0, size.height);

      final rect = Rect.fromLTRB(left, top, right, bottom);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));

      // Draw high-contrast double outline (outer black, inner white) for visibility over any background
      canvas.drawRRect(rrect, boxPaint);
      canvas.drawRRect(rrect, innerBoxPaint);

      // Label text: Object category + confidence percentage, e.g. "Person 92%"
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

      // Position label chip above box if space allows, otherwise just inside top of box
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

      // Draw label background badge and border
      canvas.drawRRect(labelRect, labelBgPaint);
      final labelBorderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawRRect(labelRect, labelBorderPaint);

      // Draw text
      textPainter.paint(canvas, Offset(labelLeft + 4, labelTop + 3));
    }
  }

  @override
  bool shouldRepaint(covariant BoundingBoxPainter oldDelegate) {
    return oldDelegate.detections != detections || oldDelegate.previewSize != previewSize;
  }
}
