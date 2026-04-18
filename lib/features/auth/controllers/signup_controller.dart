// lib/features/auth/controllers/signup_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/config/app_constants.dart';
import 'package:kc_connect/core/routes/app_routes.dart';
import 'package:kc_connect/features/auth/controllers/auth_controller.dart';
import 'package:kc_connect/core/theme/app_colors.dart';

class SignupController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  // Form controllers - declare as late to initialize in onInit
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;

  // Observable state
  final _isLoading = false.obs;
  final _obscurePassword = true.obs;
  final _obscureConfirmPassword = true.obs;
  final _selectedRole = 'Student'.obs;
  final _selectedLevel = ''.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get obscurePassword => _obscurePassword.value;
  bool get obscureConfirmPassword => _obscureConfirmPassword.value;
  String get selectedRole => _selectedRole.value;
  String get selectedLevel => _selectedLevel.value;

  final List<String> roles = ['Student', 'Alumni', 'Staff', 'Admin'];

  // Student class options — value stored in DB, label shown in UI
  static const List<Map<String, String>> studentLevels = [
    {'value': 'form_4',      'label': 'Form 4'},
    {'value': 'form_5',      'label': 'Form 5'},
    {'value': 'lower_sixth', 'label': 'Lower Sixth'},
    {'value': 'upper_sixth', 'label': 'Upper Sixth'},
  ];

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

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

  // Change role — also reset level when switching away from student
  void changeRole(String role) {
    _selectedRole.value = role;
    if (role != 'Student') _selectedLevel.value = '';
  }

  void changeLevel(String level) => _selectedLevel.value = level;

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

    if (passwordController.text.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }

    if (confirmPasswordController.text != passwordController.text) {
      return 'Passwords do not match';
    }

    if (_selectedRole.value == 'Student' && _selectedLevel.value.isEmpty) {
      return 'Please select your class';
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
        fullName: nameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        password: passwordController.text,
        role: _selectedRole.value,
        level: _selectedRole.value == 'Student' ? _selectedLevel.value : null,
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
        } else if (result['requiresEmailConfirmation'] == true) {
          // Navigate to check email screen so user knows what to do next
          Get.offNamed(
            AppRoutes.checkEmail,
            arguments: {'email': emailController.text.trim()},
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
