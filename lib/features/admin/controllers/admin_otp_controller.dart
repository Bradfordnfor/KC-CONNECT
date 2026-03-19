import 'package:get/get.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
// import 'package:supabase_flutter/supabase_flutter.dart'; // Uncomment when ready

class OTPRequest {
  final String id;
  final String otpCode;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String userRole;
  final DateTime createdAt;
  final DateTime expiresAt;
  final Map<String, dynamic> signupData;

  OTPRequest({
    required this.id,
    required this.otpCode,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.userRole,
    required this.createdAt,
    required this.expiresAt,
    required this.signupData,
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

  // Load pending OTP requests
  Future<void> loadPendingOTPs() async {
    try {
      _isLoading.value = true;

      // TODO: Replace with actual Supabase query
      // final response = await Supabase.instance.client
      //     .rpc('get_pending_otps')
      //     .execute();

      // Mock data for now
      await Future.delayed(const Duration(milliseconds: 500));

      _pendingOTPs.value = [
        OTPRequest(
          id: '1',
          otpCode: 'ABC123',
          userName: 'John Doe',
          userEmail: 'john@example.com',
          userPhone: '+237612345678',
          userRole: 'staff',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          expiresAt: DateTime.now().add(const Duration(days: 2, hours: 22)),
          signupData: {},
        ),
        OTPRequest(
          id: '2',
          otpCode: 'XYZ789',
          userName: 'Jane Smith',
          userEmail: 'jane@example.com',
          userPhone: '+237698765432',
          userRole: 'admin',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          expiresAt: DateTime.now().add(const Duration(days: 2, hours: 19)),
          signupData: {},
        ),
      ];

      _isLoading.value = false;
    } catch (e) {
      _isLoading.value = false;
      print('Error loading OTP requests: $e');
    }
  }

  // Approve OTP request
  Future<void> approveOTP(String otpId, String userName) async {
    try {
      // TODO: Call Supabase function
      // await Supabase.instance.client
      //     .rpc('approve_otp', params: {'otp_id': otpId})
      //     .execute();

      // Mock approval
      await Future.delayed(const Duration(milliseconds: 500));

      // Remove from list
      _pendingOTPs.removeWhere((otp) => otp.id == otpId);

      // TODO: Send email notification to user
      AppSnackbar.success(
        'Approved',
        'OTP approved for $userName. Email notification sent.',
      );
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to approve OTP');
    }
  }

  // Reject OTP request
  Future<void> rejectOTP(String otpId, String userName, String reason) async {
    try {
      if (reason.trim().isEmpty) {
        AppSnackbar.error(
          'Reason Required',
          'Please provide a rejection reason',
        );
        return;
      }

      // TODO: Call Supabase function
      // await Supabase.instance.client
      //     .rpc('reject_signup', params: {
      //       'otp_id': otpId,
      //       'reason': reason,
      //     })
      //     .execute();

      // Mock rejection
      await Future.delayed(const Duration(milliseconds: 500));

      // Remove from list
      _pendingOTPs.removeWhere((otp) => otp.id == otpId);

      // TODO: Send email notification to user
      AppSnackbar.success(
        'Rejected',
        'Signup rejected for $userName. Email notification sent.',
      );
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to reject OTP');
    }
  }

  // Refresh OTPs
  Future<void> refreshOTPs() async {
    await loadPendingOTPs();
  }
}
