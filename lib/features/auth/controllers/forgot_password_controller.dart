import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/features/auth/controllers/auth_controller.dart';
import 'package:kc_connect/core/theme/app_colors.dart';

class ForgotPasswordController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  // Form controller - declare as late to initialize in onInit
  late final TextEditingController emailController;

  // Observable state
  final _isLoading = false.obs;

  // Getters
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  // Send reset link
  Future<void> sendResetLink() async {
    // Validate
    if (emailController.text.trim().isEmpty) {
      _showError('Please enter your email');
      return;
    }

    if (!emailController.text.contains('@')) {
      _showError('Please enter a valid email');
      return;
    }

    _isLoading.value = true;

    try {
      final success = await _authController.resetPassword(
        emailController.text.trim(),
      );

      if (success) {
        _showSuccessDialog();
      } else {
        _showError('Failed to send reset link');
      }
    } catch (e) {
      _showError('Failed to send reset link. Please try again.');
    } finally {
      _isLoading.value = false;
    }
  }

  // Show success dialog
  void _showSuccessDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Email Sent!',
                style: Get.textTheme.titleLarge?.copyWith(
                  color: AppColors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Password reset link has been sent to ${emailController.text.trim()}',
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
                    Get.back(); // Go back to login
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

  // Navigate back to login
  void goToLogin() {
    Get.back();
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
}
