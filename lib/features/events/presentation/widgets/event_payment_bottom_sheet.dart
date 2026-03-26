import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/buttons/primary_button.dart';

class EventPaymentBottomSheet extends StatefulWidget {
  final String price;
  final String eventName;
  const EventPaymentBottomSheet({
    super.key,
    required this.price,
    required this.eventName,
  });

  @override
  State<EventPaymentBottomSheet> createState() =>
      _EventPaymentBottomSheetState();
}

class _EventPaymentBottomSheetState extends State<EventPaymentBottomSheet> {
  final TextEditingController _phoneController = TextEditingController();
  String _paymentMethod = 'mtn_momo';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Register:\n${widget.eventName}',
                    style: AppTextStyles.subHeading.copyWith(
                      color: AppColors.blue,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Amount',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              TextFormField(
                initialValue: widget.price,
                enabled: false,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixText: 'XAF ',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Phone Number',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter phone number',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Payment Method',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Radio<String>(
                    value: 'mtn_momo',
                    groupValue: _paymentMethod,
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                  ),
                  const Text('MTN MoMo'),
                  const SizedBox(width: 16),
                  Radio<String>(
                    value: 'orange_money',
                    groupValue: _paymentMethod,
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                  ),
                  const Text('Orange Money'),
                ],
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Pay Now',
                expanded: true,
                height: 48,
                onPressed: () {
                  // TODO: Integrate payment API
                  Get.back();
                  Get.snackbar(
                    'Payment',
                    'Payment prompt will be shown here (API integration pending)',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.blue,
                    colorText: AppColors.white,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 8,
                    duration: const Duration(seconds: 2),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
