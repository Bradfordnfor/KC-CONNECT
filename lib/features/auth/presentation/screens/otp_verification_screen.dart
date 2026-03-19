import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({Key? key}) : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Verify OTP with backend
      // await Supabase.instance.client.rpc('verify_otp', params: {
      //   'otp_code': _otpController.text,
      // });

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
                Icon(Icons.pending, color: AppColors.warning, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Pending Approval',
                  style: AppTextStyles.subHeading.copyWith(
                    color: AppColors.blue,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your signup request has been submitted. You will receive an email once an admin approves your account.',
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
                      Get.offAllNamed('/login');
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
        'Verification Failed',
        'Invalid OTP code',
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
    final args = Get.arguments as Map<String, dynamic>?;
    final email = args?['email'] ?? '';
    final role = args?['role'] ?? '';

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
                              Icons.verified_user,
                              color: AppColors.blue,
                              size: 40,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        Text(
                          'OTP Verification',
                          style: AppTextStyles.heading.copyWith(
                            color: AppColors.blue,
                            fontSize: 26,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Check your email for the OTP code',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // Email Info
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email,
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Role',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
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
                                  role,
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.info,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // OTP Field
                        TextFormField(
                          controller: _otpController,
                          keyboardType: TextInputType.text,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.heading.copyWith(
                            fontSize: 24,
                            letterSpacing: 8,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Enter OTP',
                            hintText: 'ABC123',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: AppColors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter OTP';
                            }
                            if (value.length < 6) {
                              return 'OTP must be 6 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Verify Button
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _verifyOTP,
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
                                    'Verify OTP',
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Resend OTP
                        Center(
                          child: TextButton(
                            onPressed: () {
                              // TODO: Resend OTP
                              Get.snackbar(
                                'OTP Resent',
                                'Check your email',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: AppColors.success,
                                colorText: AppColors.white,
                              );
                            },
                            child: Text(
                              'Resend OTP',
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
