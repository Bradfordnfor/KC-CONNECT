// lib/views/admin/pages/admin_otp_approvals_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
import 'package:kc_connect/core/widgets/loading_indicator.dart';
import 'package:kc_connect/features/admin/controllers/admin_otp_controller.dart';

class AdminOTPApprovalsPage extends StatelessWidget {
  const AdminOTPApprovalsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminOTPController());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'OTP Approvals',
          style: AppTextStyles.subHeading.copyWith(color: AppColors.blue),
        ),
        backgroundColor: AppColors.white,
        elevation: 2,
        centerTitle: true,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: LoadingIndicator());
        }

        if (controller.pendingOTPs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 64,
                  color: AppColors.success,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Pending OTPs',
                  style: AppTextStyles.subHeading.copyWith(
                    color: AppColors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'All signup requests have been processed',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshOTPs(),
          color: AppColors.blue,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.pendingOTPs.length,
            itemBuilder: (context, index) {
              final otp = controller.pendingOTPs[index];
              return _buildOTPCard(context, otp, controller);
            },
          ),
        );
      }),
    );
  }

  Widget _buildOTPCard(
    BuildContext context,
    OTPRequest otp,
    AdminOTPController controller,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person, color: AppColors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        otp.userName,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.blue,
                        ),
                      ),
                      Text(
                        otp.userEmail,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    otp.userRole.toUpperCase(),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.info,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Phone: ${otp.userPhone}',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'OTP Code: ${otp.otpCode}',
              style: AppTextStyles.body.copyWith(
                color: AppColors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Expires: ${otp.timeRemaining}',
              style: AppTextStyles.caption.copyWith(
                color: otp.isExpired
                    ? AppColors.error
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        _showRejectDialog(context, otp, controller),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Reject',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        controller.approveOTP(otp.id, otp.userName),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Approve',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(
    BuildContext context,
    OTPRequest otp,
    AdminOTPController controller,
  ) {
    final reasonController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cancel, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(
                'Reject Signup',
                style: AppTextStyles.subHeading.copyWith(color: AppColors.blue),
              ),
              const SizedBox(height: 12),
              Text(
                'Please provide a reason for rejection',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              AppMultilineField(
                label: 'Reason',
                hint: 'Enter rejection reason',
                controller: reasonController,
                minLines: 3,
                maxLines: 5,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.blue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.rejectOTP(
                          otp.id,
                          otp.userName,
                          reasonController.text,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Reject',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
