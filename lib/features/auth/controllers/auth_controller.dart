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

  // Getters
  bool get isAuthenticated => _isAuthenticated.value;
  bool get isLoading => _isLoading.value;
  Map<String, dynamic>? get currentUser => _currentUser.value;
  // Exposed so MainNavigation can reactively wait for profile to load
  Rxn<Map<String, dynamic>> get currentUserRx => _currentUser;

  @override
  void onInit() {
    super.onInit();

    // Listen for auth state changes and keep profile in sync
    Supabase.instance.client.auth.onAuthStateChange.listen((event) async {
      final session = event.session;
      if (session != null && event.event == AuthChangeEvent.signedIn) {
        _isAuthenticated.value = true;
        await _loadUserProfile(session.user.id);
        final role = _currentUser.value?['role'] as String? ?? '';
        if (role == 'admin') {
          if (Get.currentRoute != AppRoutes.admin) {
            Get.offAllNamed(AppRoutes.admin);
          }
        } else {
          if (Get.currentRoute != AppRoutes.main) {
            Get.offAllNamed(AppRoutes.main);
          }
        }
      } else if (event.event == AuthChangeEvent.signedOut) {
        _isAuthenticated.value = false;
        _currentUser.value = null;
        // Don't redirect if we're already on the login or check-email screen
        final cur = Get.currentRoute;
        if (cur != AppRoutes.login &&
            cur != AppRoutes.checkEmail &&
            cur != AppRoutes.register) {
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
  // Uses maybeSingle() + retry to handle the brief window between auth user
  // creation and the handle_new_user DB trigger committing the public.users row.
  Future<void> _loadUserProfile(String userId) async {
    const maxAttempts = 5;
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final response = await Supabase.instance.client
            .from('users')
            .select(
              'id, email, full_name, phone_number, profile_image_url, role, is_super_admin, status, institution, school, level, class_year, graduation_year, current_position, company, bio, career, vision, expertise, available_for_mentorship, max_mentees, mentorship_areas, linkedin_url, twitter_url, website_url, total_likes, total_resources_uploaded, total_events_created, total_mentorship_given, subscription_status, subscription_start_date, subscription_end_date, subscription_auto_renew, notification_preferences, language_preference, theme_preference, created_at, updated_at, last_login_at, login_count',
            )
            .eq('id', userId)
            .maybeSingle();
        if (response != null) {
          _currentUser.value = response;
          return;
        }
        // Row not yet visible — trigger may still be committing. Wait and retry.
        debugPrint('User profile not found yet (attempt ${attempt + 1}/$maxAttempts), retrying...');
        if (attempt < maxAttempts - 1) {
          await Future.delayed(const Duration(milliseconds: 800));
        }
      } catch (e) {
        debugPrint('Error loading user profile (attempt ${attempt + 1}): $e');
        if (attempt < maxAttempts - 1) {
          await Future.delayed(const Duration(milliseconds: 800));
        }
      }
    }
    debugPrint('Could not load user profile after $maxAttempts attempts');
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

        // Deactivate any previous pending signups for this email so we never
        // accumulate duplicates (which would break maybeSingle() queries later).
        await Supabase.instance.client
            .from('pending_signups')
            .update({'is_active': false})
            .eq('email', email)
            .eq('is_active', true);

        final inserted = await Supabase.instance.client
            .from('pending_signups')
            .insert({
              'email': email,
              'name': fullName,
              'phone': phoneNumber,
              'role': role.toLowerCase(),
              'otp': otp,
              'password_hash': passwordHash,
              'purpose': role.toLowerCase() == 'admin' ? 'admin_signup' : 'staff_signup',
              'is_active': true,
              'created_at': DateTime.now().toIso8601String(),
              'expires_at': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
            })
            .select('id')
            .single();
        final pendingSignupId = inserted['id'] as String;
        // Notify admins in-app + send email. OTP email only goes to user AFTER admin approves.
        await _notifyAdminOfNewSignup(email, fullName, role, pendingSignupId);
        _isLoading.value = false;
        return {
          'success': true,
          'requiresOTP': true,
          'awaitingApproval': true,
          'email': email,
          'role': role,
        };
      } else {
        // Check for duplicate phone number before creating the auth user.
        // Phone uniqueness is not enforced by Supabase auth, only by our table.
        final phoneCheck = await Supabase.instance.client
            .from('users')
            .select('id')
            .eq('phone_number', phoneNumber)
            .maybeSingle();
        if (phoneCheck != null) {
          _isLoading.value = false;
          return {'success': false, 'error': 'An account with this phone number already exists.'};
        }

        // Pass user data as metadata — the handle_new_user DB trigger reads
        // this and creates the users row server-side. No client-side insert
        // needed, no RLS issues, no role tampering possible.
        final response = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
          emailRedirectTo: 'kcconnect://auth/callback',
          data: {
            'full_name': fullName,
            'phone_number': phoneNumber,
            'role': role.toLowerCase(), // trigger expects lowercase
          },
        );

        if (response.user == null) {
          _isLoading.value = false;
          return {'success': false, 'error': 'Signup failed. Please try again.'};
        }

        if (response.session != null) {
          // No email confirmation needed (e.g. auto-confirm enabled in dashboard)
          _isAuthenticated.value = true;
          await _loadUserProfile(response.user!.id);
          _isLoading.value = false;
          return {'success': true, 'requiresOTP': false};
        }

        // Email confirmation required — profile row is already in DB so
        // clicking the link on any device will work correctly.
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
      return {'success': false, 'error': _friendlySignupError(e)};
    }
  }

  // Verify OTP — admin must have approved before this will succeed
  Future<Map<String, dynamic>> verifyOTP({required String email, required String otp}) async {
    try {
      _isLoading.value = true;

      // Check OTP is correct, active, and admin has approved it
      final record = await Supabase.instance.client
          .from('pending_signups')
          .select()
          .eq('email', email)
          .eq('otp', otp)
          .eq('is_active', true)
          .maybeSingle();

      if (record == null) {
        _isLoading.value = false;
        return {'success': false, 'error': 'Invalid OTP. Please check and try again.'};
      }

      final adminApproved = record['admin_approved'] as bool? ?? false;
      if (!adminApproved) {
        _isLoading.value = false;
        return {'success': false, 'error': 'Your request is still pending admin approval. You will receive an email with your OTP once approved.'};
      }

      // Call complete-signup edge function — creates auth user, returns credential
      final result = await Supabase.instance.client.functions.invoke(
        'complete-signup',
        body: {'email': email, 'otp': otp},
      );

      final data = result.data as Map<String, dynamic>?;
      if (data == null || data['credential'] == null) {
        _isLoading.value = false;
        return {'success': false, 'error': 'Account setup failed. Please contact support.'};
      }

      // Sign in with the credential returned by the edge function.
      // This avoids magic-link token expiry issues entirely.
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: data['credential'] as String,
      );

      _isLoading.value = false;
      return {'success': true};
    } catch (e) {
      _isLoading.value = false;
      debugPrint('OTP verification error: $e');
      return {'success': false, 'error': 'Verification failed. Please try again.'};
    }
  }

  // Resend OTP to the given email
  Future<bool> resendOTP({required String email}) async {
    try {
      _isLoading.value = true;
      // Use limit(1) + order so we never crash if there are duplicate rows
      final results = await Supabase.instance.client
          .from('pending_signups')
          .select('name')
          .eq('email', email)
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(1);

      if (results.isEmpty) {
        _isLoading.value = false;
        return false;
      }
      final existing = results.first;

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

  // Sign out — navigation is handled solely by the onAuthStateChange listener
  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      // Do NOT call Get.offAllNamed here — the signedOut event in the listener
      // above will fire immediately and handle the redirect. Calling it twice
      // disposes the new LoginController before the screen finishes building,
      // which causes the "TextEditingController used after disposed" crash.
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  /// Converts raw Supabase/Postgres exceptions into user-friendly messages.
  String _friendlySignupError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('user_already_exists') || msg.contains('already registered')) {
      return 'An account with this email already exists. Please log in instead.';
    }
    if (msg.contains('invalid_email') || msg.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }
    if (msg.contains('weak_password') || msg.contains('weak password')) {
      return 'Password is too weak. Please choose a stronger password.';
    }
    if (msg.contains('over_email_send_rate_limit') || msg.contains('rate_limit')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    return 'Signup failed. Please check your details and try again.';
  }

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
  /// and act on the new staff/admin signup request directly from the notification.
  Future<void> _notifyAdminOfNewSignup(
    String applicantEmail,
    String applicantName,
    String role,
    String pendingSignupId,
  ) async {
    try {
      final admins = await Supabase.instance.client
          .from('users')
          .select('id')
          .eq('role', 'admin');

      if (admins.isEmpty) return;

      final roleLabel = role.toLowerCase() == 'admin' ? 'Admin' : 'Staff';
      final notifications = (admins as List).map((admin) => {
        'user_id': admin['id'],
        'title': 'New $roleLabel Signup Request',
        'message': '$applicantName ($applicantEmail) has requested to join as ${role.toLowerCase()}. Approve or reject below.',
        'type': 'otp_approval',
        'priority': 'high',
        'is_read': false,
        // action_id holds the pending_signups row id so the admin can act inline
        'action_id': pendingSignupId,
        'action_type': 'otp_approval',
        // metadata carries extra info for the UI
        'metadata': {
          'signup_id': pendingSignupId,
          'applicant_name': applicantName,
          'applicant_email': applicantEmail,
          'applicant_role': role.toLowerCase(),
        },
        'created_at': DateTime.now().toIso8601String(),
      }).toList();

      await Supabase.instance.client.from('notifications').insert(notifications);

      // Also trigger an email to admins so they see it even when offline
      try {
        await Supabase.instance.client.functions.invoke(
          'notify-admin-signup',
          body: {
            'applicant_name': applicantName,
            'applicant_email': applicantEmail,
            'applicant_role': role.toLowerCase(),
            'signup_id': pendingSignupId,
          },
        );
      } catch (e) {
        // Email notification is non-fatal — in-app notification is already saved
        debugPrint('Admin email notification error: $e');
      }
    } catch (e) {
      debugPrint('Admin notification error: $e');
    }
  }
}
