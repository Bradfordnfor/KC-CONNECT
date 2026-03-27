import 'package:flutter/material.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';

/// Non-dismissible dialog shown while a Campay payment is being processed.
/// Opened and closed programmatically by [PaymentController].
class PaymentProcessingDialog extends StatelessWidget {
  const PaymentProcessingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                color: AppColors.blue,
                strokeWidth: 4,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Processing Payment',
              style: AppTextStyles.subHeading.copyWith(
                color: AppColors.blue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Check your phone — your operator will prompt you to enter your PIN to confirm.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'This may take up to 2 minutes.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
