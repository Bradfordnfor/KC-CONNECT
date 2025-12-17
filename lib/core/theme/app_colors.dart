import 'package:flutter/material.dart';

class AppColors {
  static const Color backgroundColor = Color(0xFFE6F0F7);
  static const Color blue = Color(0xFF004EB9);
  static const Color red = Color(0xFFF40105);
  static const Color deepRed = Color(0xFFC00F0C);
  static const Color white = Color(0xFFFFFFFF);
  static final Gradient gradientColor = LinearGradient(
    colors: [red, deepRed],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
