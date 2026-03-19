import 'package:flutter/material.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';

/// File upload widget with progress indicator
///
/// Usage:
/// ```dart
/// AppFileUploadProgress(
///   isUploading: true,
///   progress: 0.6,
///   fileName: 'document.pdf',
/// )
/// ```
class AppFileUploadProgress extends StatelessWidget {
  final bool isUploading;
  final double progress; // 0.0 to 1.0
  final String? fileName;
  final VoidCallback? onCancel;

  const AppFileUploadProgress({
    Key? key,
    required this.isUploading,
    this.progress = 0.0,
    this.fileName,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isUploading) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.blue.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
                strokeWidth: 3,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uploading...',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.blue,
                      ),
                    ),
                    if (fileName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        fileName!,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (onCancel != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onCancel,
                  color: AppColors.textSecondary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.blue),
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 8),

          // Progress percentage
          Text(
            '${(progress * 100).toInt()}%',
            style: AppTextStyles.body.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple uploading indicator (spinner + text)
class AppUploadingIndicator extends StatelessWidget {
  final String? message;

  const AppUploadingIndicator({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
          ),
          const SizedBox(height: 16),
          Text(
            message ?? 'Uploading...',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// File size validator helper
class FileSizeValidator {
  /// Validate file size
  /// Returns error message if file is too large, null if valid
  static String? validate(int bytes, int maxMB) {
    final maxBytes = maxMB * 1024 * 1024;
    if (bytes > maxBytes) {
      return 'File size must be less than ${maxMB}MB';
    }
    return null;
  }

  /// Format bytes to human-readable string
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Check if file type is allowed
  static bool isAllowedFileType(
    String fileName,
    List<String> allowedExtensions,
  ) {
    final extension = fileName.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }
}
