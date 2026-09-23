import 'package:flutter/material.dart';

/// Reusable application logo widget using the official asset image.
class AppLogo extends StatelessWidget {
  final double size;
  final BorderRadius? borderRadius;
  final String? semanticLabel;
  final BoxBorder? border;
  final Color? backgroundColor;

  const AppLogo({
    super.key,
    this.size = 48,
    this.borderRadius,
    this.semanticLabel,
    this.border,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(size * 0.22);

    Widget imageWidget = Image.asset(
      'assets/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: semanticLabel,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: effectiveRadius,
          ),
          child: Icon(
            Icons.visibility_rounded,
            size: size * 0.55,
            color: Colors.white,
          ),
        );
      },
    );

    if (effectiveRadius != BorderRadius.zero) {
      imageWidget = ClipRRect(
        borderRadius: effectiveRadius,
        child: imageWidget,
      );
    }

    if (border != null || backgroundColor != null) {
      imageWidget = Container(
        decoration: BoxDecoration(
          borderRadius: effectiveRadius,
          border: border,
          color: backgroundColor,
        ),
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
