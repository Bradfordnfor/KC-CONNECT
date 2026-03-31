import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/features/auth/controllers/auth_controller.dart';
import 'package:kc_connect/core/theme/app_colors.dart';

class OTPController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  late final TextEditingController otpController;

  final _isLoading = false.obs;
  final _email = ''.obs;
  final _role = ''.obs;

  bool get isLoading => _isLoading.value;
  String get email => _email.value;
  String get role => _role.value;

  @override
  void onInit() {
    super.onInit();
    otpController = TextEditingController();
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

  // Verify OTP — succeeds only after admin approves and sends OTP to user's email
  Future<void> verifyOTP() async {
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
      final result = await _authController.verifyOTP(
        email: _email.value,
        otp: otpController.text.trim().toUpperCase(),
      );

      if (result['success'] == true) {
        // Auth state listener in AuthController handles navigation automatically
      } else {
        _showError(result['error'] as String? ?? 'Verification failed. Please try again.');
      }
    } catch (e) {
      _showError('Verification failed. Please try again.');
    } finally {
      _isLoading.value = false;
    }
  }

  // Resend OTP — only relevant after admin has approved (re-sends the approved OTP)
  Future<void> resendOTP() async {
    if (_email.value.isEmpty) {
      _showError('No email on record. Please sign up again.');
      return;
    }
    _isLoading.value = true;
    final success = await _authController.resendOTP(email: _email.value);
    _isLoading.value = false;
    if (success) {
      _showSuccess('OTP resent. Check your email.');
    } else {
      _showError('Could not resend OTP. Your request may still be pending admin approval.');
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.error,
      colorText: AppColors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 4),
    );
  }

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
