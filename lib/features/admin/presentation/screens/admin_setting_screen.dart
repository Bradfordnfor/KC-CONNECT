import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTextStyles.subHeading.copyWith(color: AppColors.blue),
        ),
        backgroundColor: AppColors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.blue),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'App Configuration',
            style: AppTextStyles.subHeading.copyWith(
              color: AppColors.blue,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            'Email Notifications',
            'Manage notification settings',
            Icons.email,
          ),
          const SizedBox(height: 12),
          _buildSettingCard(
            'User Permissions',
            'Configure user roles',
            Icons.security,
          ),
          const SizedBox(height: 12),
          _buildSettingCard(
            'Backup & Restore',
            'Database management',
            Icons.backup,
          ),
          const SizedBox(height: 12),
          _buildSettingCard('System Logs', 'View activity logs', Icons.article),
          const SizedBox(height: 24),
          Text(
            'Security',
            style: AppTextStyles.subHeading.copyWith(
              color: AppColors.blue,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            '2FA Settings',
            'Two-factor authentication',
            Icons.lock,
          ),
          const SizedBox(height: 12),
          _buildSettingCard('Session Timeout', '30 minutes', Icons.timer),
        ],
      ),
    );
  }

  Widget _buildSettingCard(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.blue, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.blue,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
