import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/buttons/primary_button.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
import 'package:kc_connect/features/auth/controllers/auth_controller.dart';
import 'package:kc_connect/features/events/controllers/events_controller.dart';
import 'package:kc_connect/core/services/campay_service.dart';
import 'package:kc_connect/features/payment/controllers/payment_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventPaymentBottomSheet extends StatefulWidget {
  final String eventId;
  final String eventName;
  final String price;

  const EventPaymentBottomSheet({
    super.key,
    required this.eventId,
    required this.eventName,
    required this.price,
  });

  @override
  State<EventPaymentBottomSheet> createState() =>
      _EventPaymentBottomSheetState();
}

class _EventPaymentBottomSheetState extends State<EventPaymentBottomSheet> {
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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Register: ${widget.eventName}',
                      style: AppTextStyles.subHeading.copyWith(
                        color: AppColors.blue,
                        fontSize: 18,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed:
                        _isProcessing ? null : () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Amount (read-only)
              Text(
                'Amount',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                initialValue: widget.price,
                enabled: false,
                decoration: InputDecoration(
                  prefixText: 'XAF ',
                  filled: true,
                  fillColor: AppColors.backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Phone
              Text(
                'Mobile Money Number',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
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
                ),
              ),
              const SizedBox(height: 16),

              // Payment method
              Text(
                'Payment Method',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
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
              const SizedBox(height: 24),

              PrimaryButton(
                label: 'Pay XAF ${widget.price}',
                expanded: true,
                height: 50,
                onPressed: _isProcessing ? null : _handlePay,
              ),
            ],
          ),
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
              width: 18,
              height: 18,
              decoration:
                  BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  color:
                      selected ? AppColors.blue : AppColors.textSecondary,
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

  Future<void> _handlePay() async {
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

    // Close bottom sheet before showing processing dialog
    if (mounted) Navigator.pop(context);

    final result = await PaymentController.to.processPayment(
      phone: phone,
      amount: double.tryParse(widget.price) ?? 500,
      description: 'Event Registration: ${widget.eventName}',
      externalRef:
          'evt_${widget.eventId}_${userId}_${DateTime.now().millisecondsSinceEpoch}',
    );

    if (result == PaymentResult.success) {
      try {
        final now = DateTime.now().toIso8601String();
        await Supabase.instance.client.from('event_registrations').insert({
          'event_id': widget.eventId,
          'user_id': userId,
          'status': 'registered',
          'payment_status': 'paid',
          'payment_method': _paymentMethod,
          'payment_phone_number': CampayService.formatPhone(phone),
          'registration_date': now,
          'created_at': now,
          'updated_at': now,
        });

        // Increment event registration count
        await Supabase.instance.client.rpc(
          'increment_event_registrations',
          params: {'event_id': widget.eventId},
        ).catchError((_) async {
          // Fallback if RPC not available
          final ev = await Supabase.instance.client
              .from('events')
              .select('current_registrations')
              .eq('id', widget.eventId)
              .single();
          final current = (ev['current_registrations'] as int? ?? 0) + 1;
          await Supabase.instance.client
              .from('events')
              .update({'current_registrations': current}).eq(
                  'id', widget.eventId);
        });

        // Refresh events list to reflect new registration
        if (Get.isRegistered<EventsController>()) {
          Get.find<EventsController>().refreshEvents();
        }

        AppSnackbar.success(
            'Registered!', 'You are now registered for ${widget.eventName}.');
      } catch (e) {
        AppSnackbar.error(
          'Registration Error',
          'Payment received but registration failed. Please contact support.',
        );
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
