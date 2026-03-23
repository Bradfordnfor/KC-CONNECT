// lib/features/auth/controllers/signup_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/features/auth/controllers/auth_controller.dart';
import 'package:kc_connect/core/theme/app_colors.dart';

class SignupController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Observable state
  final _isLoading = false.obs;
  final _obscurePassword = true.obs;
  final _obscureConfirmPassword = true.obs;
  final _selectedRole = 'Student'.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get obscurePassword => _obscurePassword.value;
  bool get obscureConfirmPassword => _obscureConfirmPassword.value;
  String get selectedRole => _selectedRole.value;

  final List<String> roles = ['Student', 'Alumni', 'Staff', 'Admin'];

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    _obscurePassword.value = !_obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword.value = !_obscureConfirmPassword.value;
  }

  // Change role
  void changeRole(String role) {
    _selectedRole.value = role;
  }

  // Validate form
  String? _validateForm() {
    if (nameController.text.trim().isEmpty) {
      return 'Please enter your name';
    }

    if (emailController.text.trim().isEmpty) {
      return 'Please enter your email';
    }

    if (!emailController.text.contains('@')) {
      return 'Please enter a valid email';
    }

    if (phoneController.text.trim().isEmpty) {
      return 'Please enter your phone number';
    }

    if (passwordController.text.isEmpty) {
      return 'Please enter a password';
    }

    if (passwordController.text.length < 6) {
      return 'Password must be at least 6 characters';
    }

    if (confirmPasswordController.text != passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Handle signup
  Future<void> signup() async {
    // Validate form
    final error = _validateForm();
    if (error != null) {
      _showError(error);
      return;
    }

    _isLoading.value = true;

    try {
      final result = await _authController.signUp(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text,
        role: _selectedRole.value,
      );

      if (result['success'] == true) {
        if (result['requiresOTP'] == true) {
          // Navigate to OTP verification
          Get.toNamed(
            '/otp-verification',
            arguments: {
              'email': emailController.text.trim(),
              'role': _selectedRole.value,
            },
          );
        } else {
          // Direct signup success
          Get.offAllNamed('/main');
          _showSuccess('Account created successfully!');
        }
      } else {
        _showError(result['error'] ?? 'Signup failed');
      }
    } catch (e) {
      _showError('Signup failed. Please try again.');
    } finally {
      _isLoading.value = false;
    }
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
