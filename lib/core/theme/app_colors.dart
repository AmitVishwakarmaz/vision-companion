import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Monochrome / High-Contrast Black & White Primary Palette
  static const Color primary = Color(0xFF000000); // Pure Black
  static const Color primaryLight = Color(0xFF262626);
  static const Color primaryDark = Color(0xFF000000);

  // Secondary & Accents
  static const Color secondary = Color(0xFF1F1F1F); // Charcoal Black
  static const Color accent = Color(0xFF000000);

  // Light Mode Surfaces & Backgrounds (Pure White & Crisp Black)
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF5F5F5);
  static const Color lightBorder = Color(0xFF000000);
  static const Color lightBorderSubtle = Color(0xFFE0E0E0);
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0xFF424242);

  // Dark Mode Surfaces & Backgrounds
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF141414);
  static const Color darkSurfaceVariant = Color(0xFF222222);
  static const Color darkBorder = Color(0xFF3E3E3E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFA0A0A0);

  // Status & Feedback
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF1976D2);
}
