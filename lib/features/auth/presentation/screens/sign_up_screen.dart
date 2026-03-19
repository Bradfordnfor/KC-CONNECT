import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/config/app_constants.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = 'Student';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final List<String> _roles = ['Student', 'Alumni', 'Staff', 'Admin'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Implement Supabase signup
      // For Staff/Admin roles, generate OTP and send for approval
      // if (_selectedRole == 'Staff' || _selectedRole == 'Admin') {
      //   // Generate OTP and store signup data
      //   await sendOTPForApproval();
      //   Get.toNamed('/otp-verification');
      // } else {
      //   // Direct signup for Student/Alumni
      //   await Supabase.instance.client.auth.signUp(
      //     email: _emailController.text.trim(),
      //     password: _passwordController.text,
      //   );
      //   Get.offAllNamed(AppRoutes.main);
      // }

      // Mock signup
      await Future.delayed(const Duration(seconds: 2));

      if (_selectedRole == 'Staff' || _selectedRole == 'Admin') {
        Get.toNamed(
          '/otp-verification',
          arguments: {'email': _emailController.text, 'role': _selectedRole},
        );
      } else {
        Get.offAllNamed('/main');
      }
    } catch (e) {
      Get.snackbar(
        'Signup Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.blue),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth > 500
                    ? 400.0
                    : constraints.maxWidth;

                return Container(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo
                        Center(
                          child: Container(
                            width: 70,
                            height: 70,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              AppConstants.appIcon,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.school,
                                  color: AppColors.blue,
                                  size: 35,
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Text(
                          'Create Account',
                          style: AppTextStyles.heading.copyWith(
                            color: AppColors.blue,
                            fontSize: 26,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // Name Field
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: AppColors.white,
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter your name' : null,
                        ),

                        const SizedBox(height: 16),

                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: AppColors.white,
                          ),
                          validator: (value) {
                            if (value!.isEmpty)
                              return 'Please enter your email';
                            if (!value.contains('@'))
                              return 'Please enter a valid email';
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Phone Field
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: const Icon(Icons.phone_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: AppColors.white,
                          ),
                          validator: (value) => value!.isEmpty
                              ? 'Please enter your phone number'
                              : null,
                        ),

                        const SizedBox(height: 16),

                        // Role Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: InputDecoration(
                            labelText: 'Role',
                            prefixIcon: const Icon(Icons.work_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: AppColors.white,
                          ),
                          items: _roles.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => _selectedRole = value!),
                        ),

                        const SizedBox(height: 16),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: AppColors.white,
                          ),
                          validator: (value) {
                            if (value!.isEmpty)
                              return 'Please enter a password';
                            if (value.length < 6)
                              return 'Password must be at least 6 characters';
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Confirm Password Field
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () => setState(
                                () => _obscureConfirmPassword =
                                    !_obscureConfirmPassword,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: AppColors.white,
                          ),
                          validator: (value) {
                            if (value != _passwordController.text)
                              return 'Passwords do not match';
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Info Card for Staff/Admin
                        if (_selectedRole == 'Staff' ||
                            _selectedRole == 'Admin')
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.info.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppColors.info,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'OTP verification required for ${_selectedRole.toLowerCase()} role',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.info,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Signup Button
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSignup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: AppColors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Sign Up',
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Get.back(),
                              child: Text(
                                'Login',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
