import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
import 'package:kc_connect/features/auth/controllers/auth_controller.dart';
import 'package:kc_connect/features/payment/controllers/payment_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Returns true and shows the paywall if the current user needs a subscription.
/// Call this before any gated action: `if (checkSubscriptionGate()) return;`
bool checkSubscriptionGate() {
  final user = Get.find<AuthController>().currentUser;
  if (user == null) return false;
  final role = user['role'] as String? ?? '';
  if (role == 'admin' || role == 'staff' || role == 'alumni') return false;
  final status = user['subscription_status'] as String? ?? 'free';
  bool needsSub = status != 'premium';
  if (!needsSub) {
    final endDateStr = user['subscription_end_date'] as String?;
    if (endDateStr != null) {
      final endDate = DateTime.tryParse(endDateStr);
      if (endDate != null && DateTime.now().isAfter(endDate)) needsSub = true;
    }
  }
  if (!needsSub) return false;
  Get.dialog(const SubscriptionPaymentModal(), barrierDismissible: false);
  return true;
}

/// Mandatory paywall shown when a user tries to use a gated feature without
/// an active yearly subscription. It cannot be dismissed by tapping outside or
/// pressing the back button. The only exit is the floating "Exit" pill which
/// signs the user out and returns them to the login screen.
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

  // Role step — only shown to expired students
  // null = not yet asked, 'student' or 'alumni' = chosen
  String? _selectedRole;
  bool _showRoleStep = false;

  @override
  void initState() {
    super.initState();
    final user = Get.find<AuthController>().currentUser;
    final phone = user?['phone_number'] as String? ?? '';
    _phoneController = TextEditingController(text: phone);

    // Show the role-selection step only for students whose subscription
    // has previously expired (i.e. they have an end date in the past).
    final role = user?['role'] as String? ?? '';
    final endDateStr = user?['subscription_end_date'] as String?;
    final hasExpired = endDateStr != null &&
        DateTime.tryParse(endDateStr) != null &&
        DateTime.now().isAfter(DateTime.parse(endDateStr));

    if (role == 'student' && hasExpired) {
      _showRoleStep = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return PopScope(
      canPop: false,
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(onTap: () {}, child: const SizedBox.expand()),
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: _showRoleStep && _selectedRole == null
                      ? _buildRoleStep()
                      : _buildPaymentStep(),
                ),
              ),
            ),

            // Floating Exit pill
            Positioned(
              top: topPadding + 14,
              right: 20,
              child: GestureDetector(
                onTap: _isProcessing ? null : () => Get.back(),
                child: AnimatedOpacity(
                  opacity: _isProcessing ? 0.4 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.14),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.logout_rounded,
                            size: 15, color: Colors.black54),
                        const SizedBox(width: 5),
                        Text(
                          'Exit',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 1: Role selection (expired students only) ──────────────────────────

  Widget _buildRoleStep() {
    final name = Get.find<AuthController>().currentUser?['full_name'] as String? ?? '';
    final firstName = name.split(' ').first;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: AppColors.gradientColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.school, color: AppColors.white, size: 36),
        ),
        const SizedBox(height: 20),
        Text(
          'Welcome back${firstName.isNotEmpty ? ', $firstName' : ''}!',
          style: AppTextStyles.subHeading.copyWith(
            color: AppColors.blue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Before renewing, let us know your current status.',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            height: 1.55,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),

        // Student option
        _buildRoleTile(
          role: 'student',
          icon: Icons.menu_book_outlined,
          title: 'Still a Student',
          subtitle: 'I am currently enrolled at King David College',
        ),
        const SizedBox(height: 12),

        // Alumni option
        _buildRoleTile(
          role: 'alumni',
          icon: Icons.workspace_premium_outlined,
          title: 'I have Graduated',
          subtitle: 'I am now a KC alumni',
        ),
        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _selectedRole == null ? null : () => setState(() {}),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              disabledBackgroundColor: AppColors.blue.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Continue',
              style: AppTextStyles.body.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleTile({
    required String role,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.blue.withValues(alpha: 0.06)
              : AppColors.white,
          border: Border.all(
            color: selected ? AppColors.blue : Colors.grey[300]!,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.blue.withValues(alpha: 0.12)
                    : AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  color: selected ? AppColors.blue : AppColors.textSecondary,
                  size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: selected ? AppColors.blue : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.blue, size: 22),
          ],
        ),
      ),
    );
  }

  // ── Step 2: Payment ─────────────────────────────────────────────────────────

  Widget _buildPaymentStep() {
    final isAlumni = _selectedRole == 'alumni';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: AppColors.gradientColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.school, color: AppColors.white, size: 36),
        ),
        const SizedBox(height: 20),
        Text(
          isAlumni ? 'Welcome back, Alumni!' : 'Welcome to KC Connect!',
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
          padding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
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
            contentPadding: const EdgeInsets.symmetric(
                vertical: 14, horizontal: 12),
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
                  color: selected
                      ? AppColors.blue
                      : AppColors.textSecondary,
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
      amount: 2, // TODO: revert to 1000 before production
      description: 'KC Connect Yearly Subscription',
      externalRef: 'sub_${userId}_${DateTime.now().millisecondsSinceEpoch}',
    );

    if (result == PaymentResult.success) {
      try {
        final now = DateTime.now();
        final endDate = DateTime(now.year + 1, now.month, now.day);

        // If they selected alumni on the role step, update their role too
        final Map<String, dynamic> updates = {
          'subscription_status': 'premium',
          'subscription_start_date': now.toIso8601String(),
          'subscription_end_date': endDate.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };
        if (_selectedRole == 'alumni') {
          updates['role'] = 'alumni';
        }

        await Supabase.instance.client
            .from('users')
            .update(updates)
            .eq('id', userId);

        await Get.find<AuthController>().refreshProfile();
        Get.back();
        AppSnackbar.success(
          'Subscribed!',
          _selectedRole == 'alumni'
              ? 'Welcome to KC Connect, Alumni!'
              : 'Welcome to KC Connect Premium!',
        );
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
