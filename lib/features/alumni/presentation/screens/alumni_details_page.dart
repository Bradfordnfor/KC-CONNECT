import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/buttons/primary_button.dart';

class AlumniDetailPage extends StatelessWidget {
  final Map<String, dynamic> alumniData;

  const AlumniDetailPage({super.key, required this.alumniData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.favorite_border, color: AppColors.blue),
          onPressed: () {
            // Add to favorites
          },
        ),

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: PrimaryButton(
        label: 'Request Mentorship',
        onPressed: () {
          // Handle mentorship request
          Get.snackbar(
            'Request Sent',
            'Your mentorship request has been sent to ${alumniData['name']}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.blue,
            colorText: AppColors.white,
            margin: const EdgeInsets.all(16),
            borderRadius: 8,
          );
        },
        expanded: true,
        height: 50,
      ),
    );
  }
}
