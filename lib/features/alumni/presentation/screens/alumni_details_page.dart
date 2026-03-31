import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/buttons/primary_button.dart';
import 'package:kc_connect/core/widgets/common/animated_like_button.dart';
import 'package:kc_connect/features/alumni/controllers/alumni_controller.dart';

class AlumniDetailPage extends StatelessWidget {
  final Map<String, dynamic> alumniData;

  const AlumniDetailPage({super.key, required this.alumniData});

  @override
  Widget build(BuildContext context) {
    // Use Get.put to initialize controller if not already initialized
    final controller = Get.put(AlumniController());
    final alumniId = alumniData['id'] ?? '';

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        leading: Obx(() {
          final isLiked = controller.isAlumniLiked(alumniId);
          return IconButton(
            icon: AppLikeIcon(
              isLiked: isLiked,
              onTap: () => controller.toggleLike(alumniId),
              size: 28,
            ),
            onPressed: () => controller.toggleLike(alumniId),
          );
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildProfileHeader(),
            const SizedBox(height: 16),

            // Like count display
            Obx(() {
              final likeCount = controller.getAlumniLikeCount(alumniId);
              if (likeCount > 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: AppColors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$likeCount ${likeCount == 1 ? 'like' : 'likes'}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            const SizedBox(height: 16),
            _buildExpertiseChips(),
            const SizedBox(height: 24),
            _buildBioSection(),
            const SizedBox(height: 20),
            _buildCareerSection(),
            const SizedBox(height: 20),
            _buildVisionSection(),
            const SizedBox(height: 32),
            _buildRequestButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        // Profile Image
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.blue.withOpacity(0.3),
              width: 3,
            ),
          ),
          child: ClipOval(
            child: alumniData['imageUrl'] != null
                ? Image.asset(
                    alumniData['imageUrl'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientColor,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: AppColors.white,
                        ),
                      );
                    },
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientColor,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.white,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 16),

        // Name
        Text(
          alumniData['name'] ?? '',
          style: AppTextStyles.subHeading.copyWith(
            color: AppColors.blue,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Role
        Text(
          alumniData['role'] ?? '',
          style: AppTextStyles.body.copyWith(
            color: Colors.grey[800],
            fontSize: 15,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 4),

        // School
        Text(
          alumniData['school'] ?? '',
          style: AppTextStyles.caption.copyWith(
            color: Colors.grey[600],
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Class Info
        Text(
          alumniData['classInfo'] ?? '',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.deepRed,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildExpertiseChips() {
    final List<String> expertise =
        ((alumniData['expertise'] as List?)?.cast<String>() ?? []);
    if (expertise.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Mentorship Areas',
            style: AppTextStyles.caption.copyWith(
              color: Colors.grey[500],
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: expertise
                .map(
                  (area) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.blue.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      area,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.blue,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection() {
    return _buildSection(
      icon: Icons.menu,
      title: 'Bio',
      content: alumniData['bio'] ?? 'No bio available.',
    );
  }

  Widget _buildCareerSection() {
    return _buildSection(
      icon: Icons.work_outline,
      title: 'Career',
      content: alumniData['career'] ?? 'No career information available.',
    );
  }

  Widget _buildVisionSection() {
    return _buildSection(
      icon: Icons.visibility_outlined,
      title: 'Vision',
      content: alumniData['vision'] ?? 'No vision statement available.',
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.blue, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: AppTextStyles.body.copyWith(
              color: Colors.grey[800],
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestButton() {
    // Use Get.put instead of Get.find to ensure controller exists
    final controller = Get.put(AlumniController());
    final alumniId = alumniData['id'] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        final hasPendingRequest = controller.hasMentorshipRequest(alumniId);

        return PrimaryButton(
          label: hasPendingRequest ? 'Request Pending' : 'Request Mentorship',
          onPressed: hasPendingRequest
              ? null
              : () => controller.requestMentorship(alumniId),
          expanded: true,
          height: 50,
        );
      }),
    );
  }
}
