import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/models/product_model.dart';
import 'package:kc_connect/core/services/campay_service.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/buttons/primary_button.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
import 'package:kc_connect/core/services/rewards_service.dart';
import 'package:kc_connect/features/auth/controllers/auth_controller.dart';
import 'package:kc_connect/features/kstore/controllers/store_controller.dart';
import 'package:kc_connect/features/payment/controllers/payment_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PurchaseBottomSheet extends StatefulWidget {
  final ProductModel product;

  const PurchaseBottomSheet({super.key, required this.product});

  @override
  State<PurchaseBottomSheet> createState() => _PurchaseBottomSheetState();
}

class _PurchaseBottomSheetState extends State<PurchaseBottomSheet> {
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
                      'Purchase: ${widget.product.title}',
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
                initialValue: widget.product.price.toStringAsFixed(0),
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
                label: 'Pay ${widget.product.formattedPrice}',
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

    // Close bottom sheet before showing processing dialog.
    // Capture all widget/state values now — widget is unmounted after pop.
    final productTitle = widget.product.title;
    final productPrice = widget.product.price;
    final productId = widget.product.id;
    final productStock = widget.product.stock;
    final paymentMethod = _paymentMethod;
    final formattedPhone = CampayService.formatPhone(phone);
    final externalRef =
        'ord_${productId}_${userId}_${DateTime.now().millisecondsSinceEpoch}';

    if (mounted) Navigator.pop(context);

    final result = await PaymentController.to.processPayment(
      phone: phone,
      amount: productPrice,
      description: 'KC Store: $productTitle',
      externalRef: externalRef,
    );

    if (result == PaymentResult.success) {
      final now = DateTime.now();
      final orderNumber =
          'KC-${now.millisecondsSinceEpoch.toString().substring(7)}';

      // ── Step 1: Create the order row (critical — fail fast if this fails) ──
      String orderId;
      try {
        final orderRes = await Supabase.instance.client
            .from('orders')
            .insert({
              'user_id': userId,
              'order_number': orderNumber,
              'status': 'processing',
              'subtotal': productPrice,
              'tax': 0,
              'shipping_cost': 0,
              'discount': 0,
              'total': productPrice,
              'currency': 'XAF',
              'payment_status': 'paid',
              'payment_method': paymentMethod,
              'payment_phone_number': formattedPhone,
              'paid_at': now.toIso8601String(),
              'ordered_at': now.toIso8601String(),
            })
            .select('id')
            .single();
        orderId = orderRes['id'] as String;
      } catch (e) {
        debugPrint('Order row creation failed: $e');
        AppSnackbar.error(
          'Order Not Recorded',
          'Your payment was received but the order could not be saved. '
          'Please contact support with reference: $orderNumber',
        );
        return;
      }

      // ── Step 2: Order items (non-critical — order exists, log and continue) ──
      try {
        await Supabase.instance.client.from('order_items').insert({
          'order_id': orderId,
          'product_id': productId,
          'product_name': productTitle,
          'unit_price': productPrice,
          'quantity': 1,
          'subtotal': productPrice,
        });
      } catch (e) {
        debugPrint('order_items insert failed (order $orderNumber already created): $e');
      }

      // ── Step 3: Decrement stock ──
      try {
        final newStock = (productStock - 1).clamp(0, 9999);
        await Supabase.instance.client
            .from('products')
            .update({'stock_quantity': newStock}).eq('id', productId);
      } catch (e) {
        debugPrint('Stock decrement failed: $e');
      }

      // ── Step 4: Award points ──
      try {
        await RewardsService.awardPoints(userId, 5);
      } catch (e) {
        debugPrint('Points award failed: $e');
      }

      // ── Step 5: Refresh store ──
      if (Get.isRegistered<StoreController>()) {
        Get.find<StoreController>().loadProducts();
      }

      // ── Step 6: Notify admins ──
      try {
        final user = Get.find<AuthController>().currentUser;
        final buyerName = user?['full_name'] as String? ?? 'Unknown';
        final buyerPhone = user?['phone_number'] as String? ?? 'N/A';
        final buyerEmail = user?['email'] as String? ?? 'N/A';

        final admins = await Supabase.instance.client
            .from('users')
            .select('id')
            .eq('role', 'admin');

        if ((admins as List).isNotEmpty) {
          final notifications = admins
              .map((admin) => {
                    'user_id': admin['id'],
                    'title': 'New Product Order',
                    'message':
                        '$buyerName ordered $productTitle (XAF ${productPrice.toStringAsFixed(0)}). Contact: $buyerPhone | $buyerEmail.',
                    'type': 'announcement',
                    'priority': 'high',
                    'is_read': false,
                  })
              .toList();
          await Supabase.instance.client
              .from('notifications')
              .insert(notifications);
        }
      } catch (e) {
        debugPrint('Admin notification failed: $e');
      }

      // Show success modal only when order is confirmed in DB.
      Get.dialog(
        Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_outline,
                      color: Colors.green, size: 36),
                ),
                const SizedBox(height: 16),
                Text(
                  'Order Confirmed!',
                  style: AppTextStyles.subHeading.copyWith(
                    color: AppColors.blue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Your order #$orderNumber for $productTitle has been received.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.blue.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time,
                          color: AppColors.blue, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Our team will contact you within 24 hours to arrange delivery.',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.blue,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Got it',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
