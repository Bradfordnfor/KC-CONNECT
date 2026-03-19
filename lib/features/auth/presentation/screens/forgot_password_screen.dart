import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Send password reset email
      // await Supabase.instance.client.auth.resetPasswordForEmail(
      //   _emailController.text.trim(),
      // );

      await Future.delayed(const Duration(seconds: 2));

      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Email Sent!',
                  style: AppTextStyles.subHeading.copyWith(
                    color: AppColors.blue,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Password reset link has been sent to ${_emailController.text}',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'OK',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.white,
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
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send reset link',
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
                        // Icon
                        Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.blue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock_reset,
                              color: AppColors.blue,
                              size: 40,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        Text(
                          'Forgot Password?',
                          style: AppTextStyles.heading.copyWith(
                            color: AppColors.blue,
                            fontSize: 26,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Enter your email and we\'ll send you a reset link',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: AppColors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Send Reset Link Button
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _sendResetLink,
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
                                    'Send Reset Link',
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Back to Login
                        Center(
                          child: TextButton(
                            onPressed: () => Get.back(),
                            child: Text(
                              'Back to Login',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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
