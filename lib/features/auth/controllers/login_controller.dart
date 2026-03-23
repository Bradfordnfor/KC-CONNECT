import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/features/auth/controllers/auth_controller.dart';
import 'package:kc_connect/core/theme/app_colors.dart';

class LoginController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Observable state
  final _isLoading = false.obs;
  final _obscurePassword = true.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get obscurePassword => _obscurePassword.value;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    _obscurePassword.value = !_obscurePassword.value;
  }

  // Handle login
  Future<void> login() async {
    // Validate input
    if (emailController.text.trim().isEmpty) {
      _showError('Please enter your email');
      return;
    }

    if (!emailController.text.contains('@')) {
      _showError('Please enter a valid email');
      return;
    }

    if (passwordController.text.isEmpty) {
      _showError('Please enter your password');
      return;
    }

    if (passwordController.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    _isLoading.value = true;

    try {
      final success = await _authController.signIn(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (success) {
        // Navigate to main app
        Get.offAllNamed('/main');
        _showSuccess('Welcome back!');
      } else {
        _showError('Invalid email or password');
      }
    } catch (e) {
      _showError('Login failed. Please try again.');
    } finally {
      _isLoading.value = false;
    }
  }

  // Navigate to signup
  void goToSignup() {
    Get.toNamed('/register');
  }

  // Navigate to forgot password
  void goToForgotPassword() {
    Get.toNamed('/forgot-password');
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
