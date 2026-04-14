import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/services/campay_service.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
import 'package:kc_connect/features/payment/presentation/widgets/payment_processing_dialog.dart';

enum PaymentResult { success, failed, timeout }

class PaymentController extends GetxController {
  /// Safe singleton accessor — creates if not yet registered.
  static PaymentController get to {
    if (!Get.isRegistered<PaymentController>()) {
      Get.put(PaymentController());
    }
    return Get.find<PaymentController>();
  }

  /// Initiates a Campay collection, shows the processing dialog, and polls
  /// for a result for up to 2 minutes (24 × 5 s).
  ///
  /// The caller is responsible for DB writes on [PaymentResult.success].
  Future<PaymentResult> processPayment({
    required String phone,
    required double amount,
    required String description,
    required String externalRef,
  }) async {
    // Show non-dismissible processing dialog
    Get.dialog(
      const PaymentProcessingDialog(),
      barrierDismissible: false,
    );

    try {
      final reference = await CampayService.initiatePayment(
        phone: phone,
        amount: amount.toInt(),
        description: description,
        externalRef: externalRef,
      );

      if (reference == null) {
        Get.back();
        AppSnackbar.error(
          'Payment Failed',
          'Could not initiate payment. Check your number and try again.',
        );
        return PaymentResult.failed;
      }

      // Poll every 5 s for up to 5 min
      for (int i = 0; i < 60; i++) {
        await Future.delayed(const Duration(seconds: 5));
        final status = await CampayService.checkStatus(reference);
        debugPrint('Poll ${i + 1}/24: $status');

        if (status == 'SUCCESSFUL') {
          Get.back();
          return PaymentResult.success;
        }
        if (status == 'FAILED') {
          Get.back();
          AppSnackbar.error(
            'Payment Declined',
            'Your payment was not completed. Please try again.',
          );
          return PaymentResult.failed;
        }
      }

      // 2-minute timeout
      Get.back();
      AppSnackbar.warning(
        'Still Processing',
        'Payment is taking longer than expected. Check your MoMo balance, then try again.',
      );
      return PaymentResult.timeout;
    } catch (e) {
      Get.back();
      debugPrint('PaymentController error: $e');
      AppSnackbar.error('Error', 'An unexpected error occurred during payment.');
      return PaymentResult.failed;
    }
  }
}
