import 'package:flutter/material.dart';

class AppColors {
  // Existing colors
  static const Color backgroundColor = Color(0xFFE6F0F7);
  static const Color blue = Color(0xFF004EB9);
  static const Color red = Color(0xFFF40105);
  static const Color deepRed = Color(0xFFC00F0C);
  static const Color white = Color(0xFFFFFFFF);

  //  colors for uniform components
  static const Color success = Color(0xFF10B981);
  static const Color info = Color(0xFF0EA5E9);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = red;

  // Gradients
  static final Gradient gradientColor = LinearGradient(
    colors: [red, deepRed],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Text colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);

  // Additional UI colors
  static const Color divider = Color(0xFFE5E7EB);
  static const Color cardShadow = Color(0x1A000000);
}
