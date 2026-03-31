import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/loading_indicator.dart';
import 'package:kc_connect/features/admin/controllers/admin_settings_controller.dart';

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminSettingsController());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Settings',
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
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: LoadingIndicator());
        }
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            _buildSectionHeader('App Configuration'),
            _buildConfigSection(context, controller),
            const SizedBox(height: 24),
            _buildSectionHeader('App Info'),
            _buildInfoSection(),
            const SizedBox(height: 24),
            _buildSectionHeader('Account'),
            _buildAccountSection(context, controller),
            const SizedBox(height: 24),
          ],
        );
      }),
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

  Widget _buildConfigSection(
      BuildContext context, AdminSettingsController controller) {
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
          // Subscription fee tile
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.payments_outlined,
                  color: AppColors.success, size: 22),
            ),
            title: Text(
              'Subscription Fee',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Obx(() => Text(
                  'XAF ${controller.subscriptionFee.toStringAsFixed(0)} / month',
                  style: AppTextStyles.caption.copyWith(color: Colors.grey[600]),
                )),
            trailing: const Icon(Icons.edit_outlined,
                size: 18, color: AppColors.blue),
            onTap: () => _showFeeDialog(context, controller),
          ),
          const Divider(height: 1, indent: 60),
          // Maintenance mode tile
          Obx(() => ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.construction_outlined,
                      color: AppColors.warning, size: 22),
                ),
                title: Text(
                  'Maintenance Mode',
                  style:
                      AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  controller.maintenanceMode
                      ? 'App offline for non-admins'
                      : 'App online for all users',
                  style:
                      AppTextStyles.caption.copyWith(color: Colors.grey[600]),
                ),
                trailing: Switch(
                  value: controller.maintenanceMode,
                  onChanged: controller.toggleMaintenanceMode,
                  activeThumbColor: AppColors.warning,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
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
          _buildInfoTile(
            icon: Icons.info_outline,
            title: 'App Version',
            value: '1.0.0',
            iconColor: AppColors.blue,
          ),
          const Divider(height: 1, indent: 60),
          _buildInfoTile(
            icon: Icons.cloud_done_outlined,
            title: 'Database',
            value: 'Supabase — Connected',
            iconColor: AppColors.success,
          ),
          const Divider(height: 1, indent: 60),
          _buildInfoTile(
            icon: Icons.shield_outlined,
            title: 'Platform',
            value: 'Flutter (iOS & Android)',
            iconColor: AppColors.info,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: Text(
        value,
        style: AppTextStyles.caption.copyWith(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildAccountSection(
      BuildContext context, AdminSettingsController controller) {
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
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.lock_outline,
                  color: AppColors.blue, size: 22),
            ),
            title: Text(
              'Change Password',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Update your admin password',
              style: AppTextStyles.caption.copyWith(color: Colors.grey[600]),
            ),
            trailing: const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey),
            onTap: () => _showChangePasswordDialog(context, controller),
          ),
          const Divider(height: 1, indent: 60),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  const Icon(Icons.logout, color: AppColors.error, size: 22),
            ),
            title: Text(
              'Logout',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
            subtitle: Text(
              'Sign out of admin account',
              style: AppTextStyles.caption.copyWith(color: Colors.grey[600]),
            ),
            onTap: () => _showLogoutDialog(context, controller),
          ),
        ],
      ),
    );
  }

  void _showFeeDialog(BuildContext context, AdminSettingsController controller) {
    final feeController = TextEditingController(
      text: controller.subscriptionFee.toStringAsFixed(0),
    );

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Subscription Fee',
          style: AppTextStyles.subHeading.copyWith(color: AppColors.blue),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set the monthly subscription fee charged to students and alumni.',
              style: AppTextStyles.caption.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: feeController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Fee (XAF)',
                prefixText: 'XAF ',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppColors.blue, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel',
                style: TextStyle(color: Colors.grey[600])),
          ),
          Obx(() => ElevatedButton(
                onPressed: controller.isSaving
                    ? null
                    : () {
                        final fee =
                            double.tryParse(feeController.text.trim()) ?? 1000;
                        if (fee < 100) {
                          return;
                        }
                        Get.back();
                        controller.updateSubscriptionFee(fee);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: controller.isSaving
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Save',
                        style: TextStyle(color: AppColors.white)),
              )),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(
      BuildContext context, AdminSettingsController controller) {
    final newPwController = TextEditingController();
    final confirmPwController = TextEditingController();
    final obscureNew = true.obs;
    final obscureConfirm = true.obs;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Change Password',
          style: AppTextStyles.subHeading.copyWith(color: AppColors.blue),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => TextField(
                  controller: newPwController,
                  obscureText: obscureNew.value,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    suffixIcon: IconButton(
                      icon: Icon(obscureNew.value
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => obscureNew.value = !obscureNew.value,
                    ),
                  ),
                )),
            const SizedBox(height: 16),
            Obx(() => TextField(
                  controller: confirmPwController,
                  obscureText: obscureConfirm.value,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirm.value
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          obscureConfirm.value = !obscureConfirm.value,
                    ),
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child:
                Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPwController.text.length < 8) {
                return;
              }
              if (newPwController.text != confirmPwController.text) {
                return;
              }
              Get.back();
              controller.changePassword(newPwController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Update',
                style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(
      BuildContext context, AdminSettingsController controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Logout',
          style: AppTextStyles.subHeading.copyWith(color: AppColors.error),
        ),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child:
                Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Logout',
                style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }
}
