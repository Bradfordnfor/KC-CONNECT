// lib/features/settings/presentation/screens/settings_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _eventReminders = true;
  bool _resourceUpdates = false;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';

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
          'Settings',
          style: AppTextStyles.subHeading.copyWith(
            color: AppColors.blue,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Account'),
            _buildAccountSection(),
            const SizedBox(height: 24),
            _buildSectionHeader('Notifications'),
            _buildNotificationsSection(),
            const SizedBox(height: 24),
            _buildSectionHeader('Preferences'),
            _buildPreferencesSection(),
            const SizedBox(height: 24),
            _buildSectionHeader('About'),
            _buildAboutSection(),
            const SizedBox(height: 24),
            _buildDangerZone(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.body.copyWith(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            onTap: () {
              Get.toNamed('/profile');
            },
          ),
          const Divider(height: 1, indent: 60),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: () {
              _showChangePasswordDialog();
            },
          ),
          const Divider(height: 1, indent: 60),
          _buildSettingsTile(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: 'john.kamdem@kcconnect.com',
            trailing: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
          _buildSwitchTile(
            icon: Icons.notifications_outlined,
            title: 'Push Notifications',
            subtitle: 'Receive push notifications',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
          ),
          const Divider(height: 1, indent: 60),
          _buildSwitchTile(
            icon: Icons.email_outlined,
            title: 'Email Notifications',
            subtitle: 'Receive updates via email',
            value: _emailNotifications,
            onChanged: (value) {
              setState(() => _emailNotifications = value);
            },
          ),
          const Divider(height: 1, indent: 60),
          _buildSwitchTile(
            icon: Icons.event_outlined,
            title: 'Event Reminders',
            subtitle: 'Get notified about upcoming events',
            value: _eventReminders,
            onChanged: (value) {
              setState(() => _eventReminders = value);
            },
          ),
          const Divider(height: 1, indent: 60),
          _buildSwitchTile(
            icon: Icons.book_outlined,
            title: 'Resource Updates',
            subtitle: 'New resources notifications',
            value: _resourceUpdates,
            onChanged: (value) {
              setState(() => _resourceUpdates = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
          _buildSwitchTile(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            subtitle: 'Enable dark theme (Coming soon)',
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() => _darkModeEnabled = value);
              Get.snackbar(
                'Dark Mode',
                'Dark mode will be available in the next update!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.blue,
                colorText: AppColors.white,
              );
            },
          ),
          const Divider(height: 1, indent: 60),
          _buildSettingsTile(
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: _selectedLanguage,
            onTap: () {
              _showLanguageDialog();
            },
          ),
          const Divider(height: 1, indent: 60),
          _buildSettingsTile(
            icon: Icons.storage_outlined,
            title: 'Storage & Cache',
            subtitle: 'Manage app storage',
            onTap: () {
              _showClearCacheDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'About KC Connect',
            subtitle: 'Version 1.0.0',
            onTap: () {
              _showAboutDialog();
            },
          ),
          const Divider(height: 1, indent: 60),
          _buildSettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms & Conditions',
            onTap: () {
              Get.snackbar(
                'Terms & Conditions',
                'Opening terms and conditions...',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          const Divider(height: 1, indent: 60),
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {
              Get.snackbar(
                'Privacy Policy',
                'Opening privacy policy...',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.red.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.red.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildSettingsTile(
        icon: Icons.logout,
        title: 'Logout',
        subtitle: 'Sign out of your account',
        iconColor: AppColors.red,
        titleColor: AppColors.red,
        onTap: () {
          _showLogoutDialog();
        },
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    Color? titleColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.blue).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.blue, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(
          fontWeight: FontWeight.w600,
          color: titleColor ?? Colors.black87,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            )
          : null,
      trailing:
          trailing ??
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.blue, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.blue,
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Change Password',
          style: AppTextStyles.subHeading.copyWith(color: AppColors.blue),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.snackbar(
                'Success',
                'Password changed successfully!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.blue,
                colorText: AppColors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Language',
          style: AppTextStyles.subHeading.copyWith(color: AppColors.blue),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'French', 'Pidgin'].map((lang) {
            return RadioListTile<String>(
              title: Text(lang),
              value: lang,
              groupValue: _selectedLanguage,
              activeColor: AppColors.blue,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Clear Cache',
          style: AppTextStyles.subHeading.copyWith(color: AppColors.blue),
        ),
        content: const Text(
          'This will clear all cached data. Downloaded resources will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.snackbar(
                'Success',
                'Cache cleared successfully!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.blue,
                colorText: AppColors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'About KC Connect',
          style: AppTextStyles.subHeading.copyWith(color: AppColors.blue),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.school,
                  color: AppColors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'KC Connect',
                style: AppTextStyles.subHeading.copyWith(
                  color: AppColors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Version 1.0.0',
                style: AppTextStyles.caption.copyWith(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Connecting KCians worldwide for learning, collaboration, and growth.',
              style: AppTextStyles.body.copyWith(
                color: Colors.grey[700],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: AppTextStyles.subHeading.copyWith(color: AppColors.red),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.back();
              Get.snackbar(
                'Logged Out',
                'You have been logged out successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.blue,
                colorText: AppColors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
