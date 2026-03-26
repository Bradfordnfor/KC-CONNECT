import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/features/auth/controllers/auth_controller.dart';
import 'package:kc_connect/core/theme/app_colors.dart';

class OTPController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  // Form controller - declare as late to initialize in onInit
  late final TextEditingController otpController;

  // Observable state
  final _isLoading = false.obs;
  final _email = ''.obs;
  final _role = ''.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  String get email => _email.value;
  String get role => _role.value;

  @override
  void onInit() {
    super.onInit();
    otpController = TextEditingController();
    // Get email and role from navigation arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      _email.value = args['email'] ?? '';
      _role.value = args['role'] ?? '';
    }
  }

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }

  // Verify OTP
  Future<void> verifyOTP() async {
    // Validate
    if (otpController.text.trim().isEmpty) {
      _showError('Please enter OTP');
      return;
    }

    if (otpController.text.trim().length < 6) {
      _showError('OTP must be 6 characters');
      return;
    }

    _isLoading.value = true;

    try {
      final success = await _authController.verifyOTP(
        email: _email.value,
        otp: otpController.text.trim().toUpperCase(),
      );

      if (success) {
        // Show pending approval dialog
        _showPendingApprovalDialog();
      } else {
        _showError('Invalid OTP code');
      }
    } catch (e) {
      _showError('Verification failed. Please try again.');
    } finally {
      _isLoading.value = false;
    }
  }

  // Resend OTP
  Future<void> resendOTP() async {
    if (_email.value.isEmpty) {
      _showError('No email on record. Please sign up again.');
      return;
    }
    _isLoading.value = true;
    final success = await _authController.resendOTP(email: _email.value);
    _isLoading.value = false;
    if (success) {
      _showSuccess('A new OTP has been sent to your email');
    } else {
      _showError('Failed to resend OTP. Please try again.');
    }
  }

  // Show pending approval dialog
  void _showPendingApprovalDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pending, color: AppColors.warning, size: 48),
              const SizedBox(height: 16),
              Text(
                'Pending Approval',
                style: Get.textTheme.titleLarge?.copyWith(
                  color: AppColors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your signup request has been submitted. You will receive an email once an admin approves your account.',
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close dialog
                    Get.offAllNamed('/login'); // Go to login
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Show error message
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.error,
      colorText: AppColors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }

  // Show success message
  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: AppColors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 2),
    );
  }
}
