import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette
  static const Color background = Color(0xFFF5F0E8);
  static const Color primary = Color(0xFF5C8A3C);
  static const Color primaryLight = Color(0xFF7AB55A);
  static const Color primaryDark = Color(0xFF3D6428);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFF8B6240);
  static const Color accentLight = Color(0xFFB8865A);

  // Text
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textLight = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Semantic
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // Card / shadow
  static const Color cardShadow = Color(0x1A000000);
  static const Color divider = Color(0xFFE0D9CF);

  // Gradient
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF5C8A3C), Color(0xFF3D6428)],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5C8A3C), Color(0xFF7AB55A)],
  );

  // Bottom nav
  static const Color navBackground = Color(0xFFFFFFFF);
  static const Color navSelected = Color(0xFF5C8A3C);
  static const Color navUnselected = Color(0xFFB0B0B0);
}
