import 'package:get/get.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OTPRequest {
  final String id;
  final String otpCode;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String userRole;
  final DateTime createdAt;
  final DateTime expiresAt;

  OTPRequest({
    required this.id,
    required this.otpCode,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.userRole,
    required this.createdAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  String get timeRemaining {
    if (isExpired) return 'Expired';
    final diff = expiresAt.difference(DateTime.now());
    if (diff.inHours > 24) return '${diff.inDays} days';
    if (diff.inHours > 0) return '${diff.inHours} hours';
    return '${diff.inMinutes} minutes';
  }
}

class AdminOTPController extends GetxController {
  final _pendingOTPs = <OTPRequest>[].obs;
  final _isLoading = false.obs;

  List<OTPRequest> get pendingOTPs => _pendingOTPs;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadPendingOTPs();
  }

  Future<void> loadPendingOTPs() async {
    try {
      _isLoading.value = true;

      final response = await Supabase.instance.client
          .from('pending_signups')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      _pendingOTPs.value = (response as List).map((item) {
        return OTPRequest(
          id: item['id'].toString(),
          otpCode: item['otp'] ?? '',
          userName: item['name'] ?? '',
          userEmail: item['email'] ?? '',
          userPhone: item['phone'] ?? '',
          userRole: item['role'] ?? '',
          createdAt: DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now(),
          expiresAt: DateTime.tryParse(item['expires_at'] ?? '') ??
              DateTime.now().add(const Duration(days: 3)),
        );
      }).toList();

      _isLoading.value = false;
    } catch (e) {
      _isLoading.value = false;
      print('Error loading OTP requests: $e');
    }
  }

  // Approve: create the user via Edge Function (requires server-side auth admin)
  Future<void> approveOTP(String otpId, String userName) async {
    try {
      await Supabase.instance.client.functions.invoke(
        'approve-signup',
        body: {'signup_id': otpId},
      );

      _pendingOTPs.removeWhere((otp) => otp.id == otpId);

      AppSnackbar.success(
        'Approved',
        'Signup approved for $userName. They can now log in.',
      );
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to approve signup');
    }
  }

  // Reject: deactivate the pending signup record directly
  Future<void> rejectOTP(String otpId, String userName, String reason) async {
    try {
      if (reason.trim().isEmpty) {
        AppSnackbar.error('Reason Required', 'Please provide a rejection reason');
        return;
      }

      await Supabase.instance.client
          .from('pending_signups')
          .update({'is_active': false})
          .eq('id', otpId);

      _pendingOTPs.removeWhere((otp) => otp.id == otpId);

      AppSnackbar.success('Rejected', 'Signup rejected for $userName');
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to reject signup');
    }
  }

  Future<void> refreshOTPs() => loadPendingOTPs();
}
