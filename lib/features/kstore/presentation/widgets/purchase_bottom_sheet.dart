import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/models/product_model.dart';
import 'package:kc_connect/core/services/campay_service.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/buttons/primary_button.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
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

    // Close bottom sheet before showing processing dialog
    if (mounted) Navigator.pop(context);

    final result = await PaymentController.to.processPayment(
      phone: phone,
      amount: widget.product.price,
      description: 'KC Store: ${widget.product.title}',
      externalRef:
          'ord_${widget.product.id}_${userId}_${DateTime.now().millisecondsSinceEpoch}',
    );

    if (result == PaymentResult.success) {
      try {
        final now = DateTime.now();
        final orderNumber =
            'KC-${now.millisecondsSinceEpoch.toString().substring(7)}';

        // Insert order
        final orderRes = await Supabase.instance.client
            .from('orders')
            .insert({
              'user_id': userId,
              'order_number': orderNumber,
              'status': 'processing',
              'subtotal': widget.product.price,
              'tax': 0,
              'shipping_cost': 0,
              'discount': 0,
              'total': widget.product.price,
              'currency': 'XAF',
              'payment_status': 'paid',
              'payment_method': _paymentMethod,
              'payment_phone_number': CampayService.formatPhone(phone),
              'paid_at': now.toIso8601String(),
              'ordered_at': now.toIso8601String(),
              'created_at': now.toIso8601String(),
              'updated_at': now.toIso8601String(),
            })
            .select('id')
            .single();

        final orderId = orderRes['id'] as String;

        // Insert order item
        await Supabase.instance.client.from('order_items').insert({
          'order_id': orderId,
          'product_id': widget.product.id,
          'product_name': widget.product.title,
          'unit_price': widget.product.price,
          'quantity': 1,
          'subtotal': widget.product.price,
          'created_at': now.toIso8601String(),
        });

        // Decrement stock
        final newStock = (widget.product.stock - 1).clamp(0, 9999);
        await Supabase.instance.client
            .from('products')
            .update({'stock_quantity': newStock}).eq('id', widget.product.id);

        // Refresh store list
        if (Get.isRegistered<StoreController>()) {
          Get.find<StoreController>().loadProducts();
        }

        AppSnackbar.success(
          'Order Placed!',
          'Your order #$orderNumber has been placed successfully.',
        );
      } catch (e) {
        AppSnackbar.error(
          'Order Error',
          'Payment received but order could not be created. Please contact support.',
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
