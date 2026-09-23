import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final String? semanticLabel;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isOutlined;

  const AuthButton({
    super.key,
    required this.text,
    this.semanticLabel,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveLabel = semanticLabel ?? text;

    return Semantics(
      button: true,
      enabled: !isLoading && onPressed != null,
      label: effectiveLabel,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: isOutlined
            ? OutlinedButton(
                onPressed: isLoading ? null : onPressed,
                child: _buildChild(context),
              )
            : ElevatedButton(
                onPressed: isLoading ? null : onPressed,
                child: _buildChild(context),
              ),
      ),
    );
  }

  Widget _buildChild(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }

    return Text(text);
  }
}
