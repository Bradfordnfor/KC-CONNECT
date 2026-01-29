// lib/core/widgets/cards/alumni_card.dart
import 'package:flutter/material.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';

/// Alumni/Mentor card component matching Figma design
/// Layout: Row with [Image + Class] on left, [Name + Role + School] on right, Button at bottom
class AlumniCard extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final String role;
  final String school;
  final String classInfo;
  final VoidCallback? onTap;

  const AlumniCard({
    super.key,
    this.imageUrl,
    required this.name,
    required this.role,
    required this.school,
    required this.classInfo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          // Row with left column (image + class) and right column (info)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT COLUMN: Profile Image + Class Info
              Column(
                children: [
                  _buildProfileImage(),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 80,
                    child: Text(
                      classInfo,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.deepRed,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 16),

              // RIGHT COLUMN: Name, Role, School
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      name,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.blue,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Role
                    Text(
                      role,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.grey[800],
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // School/Location
                    Text(
                      school,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // "See more..." button at bottom (full width)
          _buildSeeMoreButton(),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.blue.withOpacity(0.2), width: 2),
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? (imageUrl!.startsWith('http')
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar();
                      },
                    )
                  : Image.asset(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar();
                      },
                    ))
            : _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.gradientColor),
      child: const Icon(Icons.person, size: 35, color: AppColors.white),
    );
  }

  Widget _buildSeeMoreButton() {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: AppColors.blue,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'See more...',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
