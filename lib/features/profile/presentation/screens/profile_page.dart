import 'package:flutter/material.dart';
import 'package:kc_connect/core/config/app_constants.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/bottom_nav_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 16),
                    _buildInfoSection(),
                    const SizedBox(height: 16),
                    _buildSettingsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Row(
        children: [
          Image.asset(AppConstants.appIcon, height: 40),
          const SizedBox(width: 12),
          Text(
            'PROFILE',
            style: AppTextStyles.subHeading.copyWith(color: AppColors.deepRed),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.blue),
            onPressed: () {
              // Navigate to edit profile
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.blue),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
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
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppColors.gradientColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 50, color: AppColors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'John Doe',
            style: AppTextStyles.subHeading.copyWith(color: AppColors.blue),
          ),
          const SizedBox(height: 4),
          Text(
            'Student • Advanced Level',
            style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'john.doe@kcconnect.com',
            style: AppTextStyles.caption.copyWith(color: AppColors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
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
            'Personal Information',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.blue,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.phone, 'Phone', '+237 123 456 789'),
          const Divider(height: 24),
          _buildInfoRow(Icons.location_on, 'Location', 'Yaoundé, Cameroon'),
          const Divider(height: 24),
          _buildInfoRow(Icons.school, 'Institution', 'Knowledge College'),
          const Divider(height: 24),
          _buildInfoRow(Icons.calendar_today, 'Joined', 'January 2024'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.blue, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
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
          _buildSettingsTile(Icons.lock, 'Privacy Policy', () {}),
          const Divider(height: 1),
          _buildSettingsTile(Icons.settings, 'Settings', () {}),
          const Divider(height: 1),
          _buildSettingsTile(Icons.help, 'Help & Support', () {}),
          const Divider(height: 1),
          _buildSettingsTile(
            Icons.logout,
            'Logout',
            () {},
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.red.withOpacity(0.1)
              : AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive ? AppColors.red : AppColors.blue,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(
          fontWeight: FontWeight.w600,
          color: isDestructive ? AppColors.red : Colors.black87,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDestructive ? AppColors.red : AppColors.blue,
      ),
      onTap: onTap,
    );
  }
}
