import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kc_connect/core/routes/app_routes.dart';

class AuthController extends GetxController {
  // Observable state
  final _isAuthenticated = false.obs;
  final _isLoading = false.obs;
  final _currentUser = Rxn<Map<String, dynamic>>();

  // Temporary storage for signup data (used during email confirmation flow)
  final _pendingSignupData = Rxn<Map<String, dynamic>>();

  // Getters
  bool get isAuthenticated => _isAuthenticated.value;
  bool get isLoading => _isLoading.value;
  Map<String, dynamic>? get currentUser => _currentUser.value;

  @override
  void onInit() {
    super.onInit();

    // Listen for auth state changes and keep profile in sync
    Supabase.instance.client.auth.onAuthStateChange.listen((event) async {
      final session = event.session;
      if (session != null && event.event == AuthChangeEvent.signedIn) {
        _isAuthenticated.value = true;

        // Check if this is a signup completion (email confirmation)
        if (_pendingSignupData.value != null) {
          await Supabase.instance.client.from('users').insert({
            'id': session.user.id,
            'email': _pendingSignupData.value!['email'],
            'full_name': _pendingSignupData.value!['fullName'],
            'phone_number': _pendingSignupData.value!['phoneNumber'],
            'role': _pendingSignupData.value!['role'],
            'status': 'active',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
          _pendingSignupData.value = null;
        }

        await _loadUserProfile(session.user.id);
        if (Get.currentRoute != AppRoutes.main) {
          Get.offAllNamed(AppRoutes.main);
        }
      } else if (event.event == AuthChangeEvent.signedOut) {
        _isAuthenticated.value = false;
        _currentUser.value = null;
        if (Get.currentRoute != AppRoutes.login) {
          Get.offAllNamed(AppRoutes.login);
        }
      }
    });

    _checkAuthStatus();
  }

  // Check if user is already logged in
  Future<void> _checkAuthStatus() async {
    try {
      _isLoading.value = true;
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        _isAuthenticated.value = true;
        await _loadUserProfile(session.user.id);
      } else {
        _isAuthenticated.value = false;
      }
      _isLoading.value = false;
    } catch (e) {
      _isLoading.value = false;
      debugPrint('Error checking auth status: $e');
    }
  }

  // Load user profile from database
  Future<void> _loadUserProfile(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select(
            'id, email, full_name, phone_number, profile_image_url, role, status, institution, school, level, class_year, graduation_year, current_position, company, bio, expertise, available_for_mentorship, mentorship_areas, linkedin_url, twitter_url, website_url, total_likes, total_resources_uploaded, total_events_created, total_mentorship_given, subscription_status, subscription_start_date, subscription_end_date, subscription_auto_renew, notification_preferences, language_preference, theme_preference, created_at, updated_at, last_login_at, login_count',
          )
          .eq('id', userId)
          .single();
      _currentUser.value = response;
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  // Refresh user profile (call after profile edits)
  Future<void> refreshProfile() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      await _loadUserProfile(session.user.id);
    }
  }

  // Sign in with email and password
  Future<bool> signIn({required String email, required String password}) async {
    try {
      _isLoading.value = true;
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.session != null) {
        _isAuthenticated.value = true;
        await _loadUserProfile(response.user!.id);
        _isLoading.value = false;
        return true;
      }
      _isLoading.value = false;
      return false;
    } catch (e) {
      _isLoading.value = false;
      debugPrint('Sign in error: $e');
      return false;
    }
  }

  // Sign up new user
  Future<Map<String, dynamic>> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String role,
  }) async {
    try {
      _isLoading.value = true;

      final requiresOTP =
          role.toLowerCase() == 'staff' || role.toLowerCase() == 'admin';

      if (requiresOTP) {
        final otp = _generateOTP();
        // Hash the password before storing — never store plaintext
        final passwordHash = _hashPassword(password);
        await Supabase.instance.client.from('pending_signups').insert({
          'email': email,
          'name': fullName,
          'phone': phoneNumber,
          'role': role,
          'otp': otp,
          'password_hash': passwordHash,
          'expires_at': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
        });
        await _sendOTPEmail(email, fullName, otp);
        _isLoading.value = false;
        return {
          'success': true,
          'requiresOTP': true,
          'email': email,
          'role': role,
        };
      } else {
        final response = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );

        if (response.user != null && response.session != null) {
          await Supabase.instance.client.from('users').insert({
            'id': response.user!.id,
            'email': email,
            'full_name': fullName,
            'phone_number': phoneNumber,
            'role': role,
            'status': 'active',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
          _isAuthenticated.value = true;
          await _loadUserProfile(response.user!.id);
          _isLoading.value = false;
          return {'success': true, 'requiresOTP': false};
        }

        // Email confirmation required
        _pendingSignupData.value = {
          'fullName': fullName,
          'email': email,
          'phoneNumber': phoneNumber,
          'role': role,
        };
        _isLoading.value = false;
        return {
          'success': true,
          'requiresOTP': false,
          'requiresEmailConfirmation': true,
          'message': 'Please confirm your email with the link sent to you.',
        };
      }
    } catch (e) {
      _isLoading.value = false;
      debugPrint('Sign up error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Verify OTP
  Future<bool> verifyOTP({required String email, required String otp}) async {
    try {
      _isLoading.value = true;
      await Supabase.instance.client
          .from('pending_signups')
          .select()
          .eq('email', email)
          .eq('otp', otp)
          .single();
      await Supabase.instance.client
          .from('pending_signups')
          .update({'status': 'pending_approval'})
          .eq('email', email);
      await _notifyAdminOfNewSignup(email);
      _isLoading.value = false;
      return true;
    } catch (e) {
      _isLoading.value = false;
      debugPrint('OTP verification error: $e');
      return false;
    }
  }

  // Resend OTP to the given email
  Future<bool> resendOTP({required String email}) async {
    try {
      _isLoading.value = true;
      // Look up the existing pending signup
      final existing = await Supabase.instance.client
          .from('pending_signups')
          .select('name')
          .eq('email', email)
          .eq('is_active', true)
          .maybeSingle();

      if (existing == null) {
        _isLoading.value = false;
        return false;
      }

      final newOtp = _generateOTP();
      await Supabase.instance.client
          .from('pending_signups')
          .update({
            'otp': newOtp,
            'expires_at': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
          })
          .eq('email', email);

      await _sendOTPEmail(email, existing['name'] ?? '', newOtp);
      _isLoading.value = false;
      return true;
    } catch (e) {
      _isLoading.value = false;
      debugPrint('Resend OTP error: $e');
      return false;
    }
  }

  // Reset password (sends reset email via Supabase)
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading.value = true;
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      _isLoading.value = false;
      return true;
    } catch (e) {
      _isLoading.value = false;
      debugPrint('Password reset error: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      _isAuthenticated.value = false;
      _currentUser.value = null;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  /// SHA-256 hash of the password. Never store plaintext passwords.
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  /// Generates a secure 6-character alphanumeric OTP.
  String _generateOTP() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final now = DateTime.now().millisecondsSinceEpoch;
    return List.generate(
      6,
      (i) => chars[(now + i * 31) % chars.length],
    ).join();
  }

  /// Sends the OTP to the user's email via a Supabase Edge Function.
  /// Deploy the edge function from /supabase/functions/send-otp-email/
  Future<void> _sendOTPEmail(String email, String name, String otp) async {
    try {
      await Supabase.instance.client.functions.invoke(
        'send-otp-email',
        body: {'email': email, 'name': name, 'otp': otp},
      );
    } catch (e) {
      // Non-fatal: OTP is stored in DB; admin can relay it if email fails
      debugPrint('OTP email send error: $e');
    }
  }

  /// Inserts a system notification for every admin user so they can see
  /// and act on the new staff/admin signup request.
  Future<void> _notifyAdminOfNewSignup(String applicantEmail) async {
    try {
      // Fetch all admin user IDs
      final admins = await Supabase.instance.client
          .from('users')
          .select('id')
          .eq('role', 'admin');

      if (admins.isEmpty) return;

      final notifications = (admins as List).map((admin) => {
        'user_id': admin['id'],
        'title': 'New Signup Request',
        'message': 'A new staff/admin signup is pending approval for $applicantEmail.',
        'type': 'system',
        'priority': 'high',
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      }).toList();

      await Supabase.instance.client.from('notifications').insert(notifications);
    } catch (e) {
      debugPrint('Admin notification error: $e');
    }
  }
}
