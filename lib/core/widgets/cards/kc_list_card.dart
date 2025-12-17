import 'package:flutter/material.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';

class KCListCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String meta;
  final VoidCallback? onTap;
  final Widget? rightWidget;
  final Color? borderColor;

  const KCListCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.meta,
    this.icon = Icons.insert_drive_file,
    this.onTap,
    this.rightWidget,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final border = borderColor ?? AppColors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon tile
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.backgroundColor,
              ),
              child: Icon(icon, color: AppColors.blue, size: 28),
            ),

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    meta,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.blue.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Right widget or arrow
            if (rightWidget != null)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: rightWidget!,
              )
            else
              Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.blue),
          ],
        ),
      ),
    );
  }
}
