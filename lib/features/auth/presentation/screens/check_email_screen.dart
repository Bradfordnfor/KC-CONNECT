// lib/features/auth/presentation/screens/check_email_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/routes/app_routes.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckEmailScreen extends StatefulWidget {
  const CheckEmailScreen({super.key});

  @override
  State<CheckEmailScreen> createState() => _CheckEmailScreenState();
}

class _CheckEmailScreenState extends State<CheckEmailScreen> {
  bool _resending = false;
  bool _resentSuccess = false;

  String get _email =>
      (Get.arguments as Map<String, dynamic>?)?['email'] as String? ?? '';

  Future<void> _resend() async {
    setState(() { _resending = true; _resentSuccess = false; });
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: _email,
      );
      if (mounted) setState(() => _resentSuccess = true);
    } catch (e) {
      if (mounted) {
        Get.snackbar('Error', 'Could not resend. Try again later.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.error,
            colorText: AppColors.white);
      }
    } finally {
      if (mounted) setState(() => _resending = false);
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
          onPressed: () => Get.offAllNamed(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mark_email_unread_outlined,
                      size: 52, color: AppColors.blue),
                ),
                const SizedBox(height: 32),

                Text(
                  'Check Your Email',
                  style: AppTextStyles.heading.copyWith(
                      color: AppColors.blue, fontSize: 26),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                Text(
                  'We sent a confirmation link to',
                  style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  _email,
                  style: AppTextStyles.body.copyWith(
                      color: AppColors.blue, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.blue.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _step('1', 'Open your email inbox'),
                      const SizedBox(height: 12),
                      _step('2', 'Find the email from KC Connect'),
                      const SizedBox(height: 12),
                      _step('3', 'Click the confirmation link'),
                      const SizedBox(height: 12),
                      _step('4',
                          'You\'ll be signed in automatically and redirected to the app'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Resend button
                if (_resentSuccess)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle,
                            color: AppColors.success, size: 18),
                        const SizedBox(width: 8),
                        Text('Email resent!',
                            style: AppTextStyles.body
                                .copyWith(color: AppColors.success)),
                      ],
                    ),
                  ),

                OutlinedButton.icon(
                  onPressed: _resending ? null : _resend,
                  icon: _resending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.blue),
                        )
                      : const Icon(Icons.refresh, color: AppColors.blue),
                  label: Text(_resending ? 'Sending...' : 'Resend Email',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.blue, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: AppColors.blue),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.login),
                  child: Text(
                    'Back to Login',
                    style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _step(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
              color: AppColors.blue, shape: BoxShape.circle),
          child: Center(
            child: Text(number,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: AppTextStyles.body
                  .copyWith(color: Colors.black87, fontSize: 14)),
        ),
      ],
    );
  }
}
