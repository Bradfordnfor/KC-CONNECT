import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
import 'package:kc_connect/features/auth/controllers/auth_controller.dart';
import 'package:kc_connect/features/payment/controllers/payment_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Non-dismissible dialog shown immediately after first login if the user
/// does not have an active yearly subscription (XAF 1,000).
class SubscriptionPaymentModal extends StatefulWidget {
  const SubscriptionPaymentModal({super.key});

  @override
  State<SubscriptionPaymentModal> createState() =>
      _SubscriptionPaymentModalState();
}

class _SubscriptionPaymentModalState extends State<SubscriptionPaymentModal> {
  late final TextEditingController _phoneController;
  String _paymentMethod = 'mtn_mobile_money';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final phone =
        Get.find<AuthController>().currentUser?['phone_number'] as String? ??
            '';
    _phoneController = TextEditingController(text: phone);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppColors.gradientColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.school,
                color: AppColors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Welcome to KC Connect!',
              style: AppTextStyles.subHeading.copyWith(
                color: AppColors.blue,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Activate your yearly membership to unlock all features — resources, events, the K-Store, and more.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                height: 1.55,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Price badge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.blue.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star_rounded,
                      color: AppColors.blue, size: 22),
                  const SizedBox(width: 10),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'XAF 1,000 ',
                          style: AppTextStyles.subHeading.copyWith(
                            color: AppColors.blue,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: '/ year',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Phone field
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Mobile Money Number',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.blue,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'e.g. 677 000 000',
                filled: true,
                fillColor: AppColors.backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AppColors.blue.withValues(alpha: 0.2),
                  ),
                ),
                prefixIcon:
                    const Icon(Icons.phone_outlined, color: AppColors.blue),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              ),
            ),
            const SizedBox(height: 16),

            // Payment method selector
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Payment Method',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.blue,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildMethodTile(
                    method: 'mtn_mobile_money',
                    label: 'MTN MoMo',
                    dotColor: Colors.amber,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMethodTile(
                    method: 'orange_money',
                    label: 'Orange Money',
                    dotColor: Colors.deepOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Subscribe button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _handleSubscribe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  disabledBackgroundColor:
                      AppColors.blue.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Subscribe Now — XAF 1,000',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You will be prompted on your phone to confirm.\nSubscription renews annually.',
              style: AppTextStyles.caption.copyWith(
                color: Colors.grey[500],
                fontSize: 11,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodTile({
    required String method,
    required String label,
    required Color dotColor,
  }) {
    final selected = _paymentMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.blue.withValues(alpha: 0.07)
              : AppColors.white,
          border: Border.all(
            color: selected ? AppColors.blue : Colors.grey[300]!,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  fontWeight:
                      selected ? FontWeight.bold : FontWeight.w500,
                  color: selected ? AppColors.blue : AppColors.textSecondary,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubscribe() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      AppSnackbar.error(
          'Phone Required', 'Please enter your mobile money number.');
      return;
    }

    setState(() => _isProcessing = true);

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      setState(() => _isProcessing = false);
      return;
    }

    final result = await PaymentController.to.processPayment(
      phone: phone,
      amount: 1000,
      description: 'KC Connect Yearly Subscription',
      externalRef: 'sub_${userId}_${DateTime.now().millisecondsSinceEpoch}',
    );

    if (result == PaymentResult.success) {
      try {
        final now = DateTime.now();
        final endDate = DateTime(now.year + 1, now.month, now.day);
        await Supabase.instance.client.from('users').update({
          'subscription_status': 'premium',
          'subscription_start_date': now.toIso8601String(),
          'subscription_end_date': endDate.toIso8601String(),
          'updated_at': now.toIso8601String(),
        }).eq('id', userId);

        await Get.find<AuthController>().refreshProfile();
        Get.back(); // close this modal
        AppSnackbar.success(
            'Subscribed!', 'Welcome to KC Connect Premium! 🎉');
        return;
      } catch (e) {
        AppSnackbar.error(
          'Activation Error',
          'Payment received but subscription could not be activated. Please contact support.',
        );
      }
    }

    if (mounted) setState(() => _isProcessing = false);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
