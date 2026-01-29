// lib/core/widgets/cards/kc_list_card.dart
import 'package:flutter/material.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';

/// Reusable list card for resources and events
/// Matches Figma design with icon/image on left, content in middle, arrow on right
class KCListCard extends StatelessWidget {
  final String? imageUrl;
  final IconData? icon;
  final String title;
  final String subtitle;
  final String? meta;
  final VoidCallback? onTap;
  final Widget? rightWidget;
  final String? tag;
  final Color? tagColor;

  const KCListCard({
    super.key,
    this.imageUrl,
    this.icon,
    required this.title,
    required this.subtitle,
    this.meta,
    this.onTap,
    this.rightWidget,
    this.tag,
    this.tagColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
        child: Row(
          children: [
            // Left: Icon/Image with optional tag
            _buildLeftSection(),

            const SizedBox(width: 14),

            // Middle: Content (title, subtitle, meta)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Subtitle
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (meta != null) ...[
                    const SizedBox(height: 4),

                    // Meta info (e.g., "Host: Sir Bradford")
                    Text(
                      meta!,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Right: Custom widget or arrow
            if (rightWidget != null)
              rightWidget!
            else
              Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftSection() {
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        children: [
          // Image or Icon container
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.backgroundColor,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? (imageUrl!.startsWith('http')
                        ? Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildIconFallback();
                            },
                          )
                        : Image.asset(
                            imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildIconFallback();
                            },
                          ))
                  : _buildIconFallback(),
            ),
          ),

          // Tag/Label (e.g., "Resource", "Event")
          if (tag != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: tagColor ?? AppColors.blue,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  tag!,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIconFallback() {
    return Icon(
      icon ?? Icons.insert_drive_file,
      color: AppColors.blue,
      size: 24,
    );
  }
}
