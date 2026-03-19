import 'package:flutter/material.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';

/// Uniform dialog component for consistent dialogs across the app
///
/// Usage:
/// ```dart
/// AppDialog.confirm(
///   context: context,
///   title: 'Delete Resource',
///   message: 'Are you sure you want to delete this resource?',
///   onConfirm: () => deleteResource(),
/// );
/// ```
class AppDialog {
  /// Show confirmation dialog
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Color confirmColor = AppColors.blue,
    IconData? icon,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.blue, size: 24),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.subHeading.copyWith(
                  color: AppColors.blue,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
              onCancel?.call();
            },
            child: Text(
              cancelText,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
              onConfirm?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              confirmText,
              style: AppTextStyles.body.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show delete confirmation (red accent)
  static Future<bool?> confirmDelete({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onConfirm,
  }) {
    return confirm(
      context: context,
      title: title,
      message: message,
      confirmText: 'Delete',
      confirmColor: AppColors.error,
      icon: Icons.delete_outline,
      onConfirm: onConfirm,
    );
  }

  /// Show info dialog
  static Future<void> info({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    IconData? icon,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.info, size: 24),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.subHeading.copyWith(
                  color: AppColors.blue,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              buttonText,
              style: AppTextStyles.body.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show error dialog
  static Future<void> error({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    return info(
      context: context,
      title: title,
      message: message,
      buttonText: buttonText,
      icon: Icons.error_outline,
    );
  }

  /// Show success dialog
  static Future<void> success({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.subHeading.copyWith(
                  color: AppColors.success,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              buttonText,
              style: AppTextStyles.body.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
