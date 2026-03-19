// lib/views/admin/widgets/metric_card.dart
import 'package:flutter/material.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const MetricCard({
    Key? key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.backgroundColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: FittedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (color ?? AppColors.blue).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color ?? AppColors.blue, size: 24),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    value,
                    style: AppTextStyles.subHeading.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blue,
                    ),
                  ),
                ],
              ),

              // Title
              Text(
                title,
                style: AppTextStyles.body.copyWith(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),

              // Subtitle (optional)
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
