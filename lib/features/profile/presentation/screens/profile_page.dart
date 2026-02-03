// lib/features/profile/presentation/screens/profile_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/buttons/primary_button.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.blue),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Profile',
          style: AppTextStyles.subHeading.copyWith(
            color: AppColors.blue,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.blue),
            onPressed: () => Get.toNamed('/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildProfileHeader(),
            const SizedBox(height: 32),
            _buildInfoSection(),
            const SizedBox(height: 24),
            _buildStatsSection(),
            const SizedBox(height: 24),
            _buildActivitySection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppColors.gradientColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.red.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.person, color: AppColors.white, size: 50),
        ),
        const SizedBox(height: 16),
        Text(
          'John Kamdem',
          style: AppTextStyles.heading.copyWith(
            color: AppColors.blue,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Student',
          style: AppTextStyles.body.copyWith(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Knowledge College',
          style: AppTextStyles.caption.copyWith(
            color: Colors.grey[500],
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 160,
          child: PrimaryButton(
            label: 'Edit Profile',
            onPressed: () => Get.toNamed('/settings'),
            height: 40,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
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
          Text(
            'Information',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.blue,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.email, 'Email', 'john.kamdem@kcconnect.com'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.phone, 'Phone', '+237 123 456 789'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.school, 'Level', 'Advanced Level'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.calendar_today, 'Class', 'Class of 2024'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.blue, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: Colors.grey[600],
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.event,
            label: 'Events',
            value: '2',
            color: AppColors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.bookmark,
            label: 'Saved',
            value: '3',
            color: AppColors.deepRed,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.download,
            label: 'Downloads',
            value: '12',
            color: AppColors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.subHeading.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.grey[600],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection() {
    return Container(
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
              Icon(Icons.history, color: AppColors.blue, size: 24),
              const SizedBox(width: 12),
              Text(
                'Recent Activity',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.blue,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            icon: Icons.event,
            title: 'Registered for STEM Quest',
            time: '2 days ago',
            color: AppColors.blue,
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            icon: Icons.download,
            title: 'Downloaded Mathematics Past Paper',
            time: '5 days ago',
            color: AppColors.deepRed,
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            icon: Icons.bookmark,
            title: 'Saved Physics Study Guide',
            time: '1 week ago',
            color: AppColors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String time,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.grey[500],
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
