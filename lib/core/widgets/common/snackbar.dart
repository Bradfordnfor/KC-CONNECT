import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';

/// Uniform snackbar component for consistent notifications across the app
///
/// Usage:
/// ```dart
/// AppSnackbar.success('Success', 'Resource uploaded successfully');
/// AppSnackbar.error('Error', 'Failed to upload resource');
/// AppSnackbar.info('Info', 'Processing your request');
/// AppSnackbar.warning('Warning', 'File size is large');
/// ```
class AppSnackbar {
  /// Show success snackbar (green)
  static void success(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: AppColors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.check_circle, color: AppColors.white),
      duration: const Duration(milliseconds: 1800),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  /// Show error snackbar (red)
  static void error(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.error,
      colorText: AppColors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.error, color: AppColors.white),
      duration: const Duration(milliseconds: 2500),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  /// Show info snackbar (light blue)
  static void info(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.info,
      colorText: AppColors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.info, color: AppColors.white),
      duration: const Duration(milliseconds: 1800),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  /// Show warning snackbar (orange)
  static void warning(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.warning,
      colorText: AppColors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.warning, color: AppColors.white),
      duration: const Duration(milliseconds: 2000),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  /// Show custom snackbar with custom color
  static void custom({
    required String title,
    required String message,
    required Color backgroundColor,
    Color textColor = AppColors.white,
    IconData? icon,
    Duration? duration,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor,
      colorText: textColor,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: icon != null ? Icon(icon, color: textColor) : null,
      duration: duration ?? const Duration(milliseconds: 1800),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }
}
