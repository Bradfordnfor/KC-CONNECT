import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
import 'package:kc_connect/features/auth/controllers/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser;
    if (user == null) return;

    // Load from user's DB preferences (source of truth)
    final prefs = user['notification_preferences'] as Map<String, dynamic>?;
    if (prefs != null) {
      setState(() {
        _notificationsEnabled = prefs['push'] as bool? ?? true;
        _emailNotifications = prefs['email'] as bool? ?? true;
        _eventReminders = prefs['events'] as bool? ?? true;
        _resourceUpdates = prefs['resources'] as bool? ?? false;
      });
    }

    final lang = user['language_preference'] as String?;
    if (lang != null && lang.isNotEmpty) {
      setState(() => _selectedLanguage = lang);
    }
  }

  Future<void> _saveNotificationPrefs() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final prefs = {
        'push': _notificationsEnabled,
        'email': _emailNotifications,
        'events': _eventReminders,
        'resources': _resourceUpdates,
      };

      // Persist locally
      final sp = await SharedPreferences.getInstance();
      await sp.setBool('notif_push', _notificationsEnabled);
      await sp.setBool('notif_email', _emailNotifications);
      await sp.setBool('notif_events', _eventReminders);
      await sp.setBool('notif_resources', _resourceUpdates);

      // Persist to DB
      await Supabase.instance.client
          .from('users')
          .update({'notification_preferences': prefs})
          .eq('id', userId);
    } catch (e) {
      debugPrint('Failed to save notification prefs: $e');
    }
  }

  Future<void> _saveLanguage(String language) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final sp = await SharedPreferences.getInstance();
      await sp.setString('language', language);

      await Supabase.instance.client
          .from('users')
          .update({'language_preference': language})
          .eq('id', userId);
    } catch (e) {
      debugPrint('Failed to save language: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

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
            _buildAccountSection(authController),
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
            _buildDangerZone(authController),
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

  Widget _buildAccountSection(AuthController authController) {
    final email = authController.currentUser?['email'] as String? ?? '';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
            onTap: () => Get.toNamed('/profile'),
          ),
          const Divider(height: 1, indent: 60),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: _showChangePasswordDialog,
          ),
          const Divider(height: 1, indent: 60),
          _buildSettingsTile(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: email.isEmpty ? '—' : email,
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
            color: Colors.black.withValues(alpha: 0.05),
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
              _saveNotificationPrefs();
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
              _saveNotificationPrefs();
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
              _saveNotificationPrefs();
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
              _saveNotificationPrefs();
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
            color: Colors.black.withValues(alpha: 0.05),
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
              AppSnackbar.info(
                'Dark Mode',
                'Dark mode will be available in the next update!',
              );
            },
          ),
          const Divider(height: 1, indent: 60),
          _buildSettingsTile(
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: _selectedLanguage,
            onTap: _showLanguageDialog,
          ),
          const Divider(height: 1, indent: 60),
          _buildSettingsTile(
            icon: Icons.storage_outlined,
            title: 'Storage & Cache',
            subtitle: 'Manage app storage',
            onTap: _showClearCacheDialog,
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
            color: Colors.black.withValues(alpha: 0.05),
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
            onTap: _showAboutDialog,
          ),
          const Divider(height: 1, indent: 60),
          _buildSettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms & Conditions',
            onTap: () => AppSnackbar.info(
              'Coming Soon',
              'Terms & Conditions will be available soon',
            ),
          ),
          const Divider(height: 1, indent: 60),
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () => AppSnackbar.info(
              'Coming Soon',
              'Privacy Policy will be available soon',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(AuthController authController) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.red.withValues(alpha: 0.05),
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
        onTap: () => _showLogoutDialog(authController),
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
          color: (iconColor ?? AppColors.blue).withValues(alpha: 0.1),
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
      trailing: trailing ??
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
          color: AppColors.blue.withValues(alpha: 0.1),
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
        activeThumbColor: AppColors.blue,
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPwController = TextEditingController();
    final newPwController = TextEditingController();
    final confirmPwController = TextEditingController();

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
              controller: currentPwController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPwController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPwController,
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
            onPressed: () async {
              if (newPwController.text != confirmPwController.text) {
                AppSnackbar.error('Mismatch', 'Passwords do not match');
                return;
              }
              if (newPwController.text.length < 8) {
                AppSnackbar.error('Too Short', 'Password must be at least 8 characters');
                return;
              }
              try {
                await Supabase.instance.client.auth.updateUser(
                  UserAttributes(password: newPwController.text),
                );
                if (context.mounted) Navigator.pop(context);
                AppSnackbar.success('Updated', 'Password changed successfully');
              } catch (e) {
                AppSnackbar.error('Error', 'Failed to change password');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue),
            child: const Text('Change', style: TextStyle(color: AppColors.white)),
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
        content: RadioGroup<String>(
          groupValue: _selectedLanguage,
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedLanguage = value);
              _saveLanguage(value);
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['English', 'French', 'Pidgin'].map((lang) {
              return RadioListTile<String>(
                title: Text(lang),
                value: lang,
              );
            }).toList(),
          ),
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
            onPressed: () async {
              final sp = await SharedPreferences.getInstance();
              await sp.clear();
              if (context.mounted) Navigator.pop(context);
              AppSnackbar.success('Cleared', 'Cache cleared successfully');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Clear', style: TextStyle(color: AppColors.white)),
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
                child: const Icon(Icons.school, color: AppColors.white, size: 40),
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

  void _showLogoutDialog(AuthController authController) {
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
              authController.signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Logout', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }
}
