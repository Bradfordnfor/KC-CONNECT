import 'package:get/get.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  // Observable state
  final _isAuthenticated = false.obs;
  final _isLoading = false.obs;
  final _currentUser = Rxn<Map<String, dynamic>>();

  // Getters
  bool get isAuthenticated => _isAuthenticated.value;
  bool get isLoading => _isLoading.value;
  Map<String, dynamic>? get currentUser => _currentUser.value;

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  // Check if user is already logged in
  Future<void> _checkAuthStatus() async {
    try {
      _isLoading.value = true;

      // TODO: Check Supabase session
      // final session = Supabase.instance.client.auth.currentSession;
      // if (session != null) {
      //   _isAuthenticated.value = true;
      //   await _loadUserProfile(session.user.id);
      // }

      // Mock check
      await Future.delayed(const Duration(milliseconds: 500));
      _isAuthenticated.value = false;

      _isLoading.value = false;
    } catch (e) {
      _isLoading.value = false;
      print('Error checking auth status: $e');
    }
  }

  // Load user profile from database
  Future<void> _loadUserProfile(String userId) async {
    try {
      // TODO: Fetch user data from Supabase
      // final response = await Supabase.instance.client
      //     .from('users')
      //     .select()
      //     .eq('id', userId)
      //     .single();

      // _currentUser.value = response;

      // Mock data
      _currentUser.value = {
        'id': userId,
        'name': 'John Doe',
        'email': 'john@example.com',
        'role': 'student',
      };
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  // Sign in with email and password
  Future<bool> signIn({required String email, required String password}) async {
    try {
      _isLoading.value = true;

      // TODO: Supabase sign in
      // final response = await Supabase.instance.client.auth.signInWithPassword(
      //   email: email,
      //   password: password,
      // );
      //
      // if (response.session != null) {
      //   _isAuthenticated.value = true;
      //   await _loadUserProfile(response.user!.id);
      //   return true;
      // }

      // Mock sign in
      await Future.delayed(const Duration(seconds: 1));
      _isAuthenticated.value = true;
      _currentUser.value = {
        'id': '123',
        'name': 'John Doe',
        'email': email,
        'role': 'student',
      };

      _isLoading.value = false;
      return true;
    } catch (e) {
      _isLoading.value = false;
      print('Sign in error: $e');
      return false;
    }
  }

  // Sign up new user
  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      _isLoading.value = true;

      // Check if role requires OTP
      final requiresOTP =
          role.toLowerCase() == 'staff' || role.toLowerCase() == 'admin';

      if (requiresOTP) {
        // Generate OTP and store signup data
        // TODO: Generate OTP and store in database
        // final otp = _generateOTP();
        // await Supabase.instance.client.from('pending_signups').insert({
        //   'email': email,
        //   'name': name,
        //   'phone': phone,
        //   'role': role,
        //   'otp': otp,
        //   'password_hash': password, // Hash this!
        //   'expires_at': DateTime.now().add(Duration(days: 3)),
        // });
        //
        // // Send OTP email
        // await _sendOTPEmail(email, otp);

        _isLoading.value = false;
        return {
          'success': true,
          'requiresOTP': true,
          'email': email,
          'role': role,
        };
      } else {
        // Direct signup for student/alumni
        // TODO: Supabase sign up
        // final response = await Supabase.instance.client.auth.signUp(
        //   email: email,
        //   password: password,
        // );
        //
        // if (response.user != null) {
        //   // Create user profile
        //   await Supabase.instance.client.from('users').insert({
        //     'id': response.user!.id,
        //     'name': name,
        //     'email': email,
        //     'phone': phone,
        //     'role': role,
        //   });
        //
        //   _isAuthenticated.value = true;
        //   await _loadUserProfile(response.user!.id);
        // }

        _isLoading.value = false;
        return {'success': true, 'requiresOTP': false};
      }
    } catch (e) {
      _isLoading.value = false;
      print('Sign up error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Verify OTP
  Future<bool> verifyOTP({required String email, required String otp}) async {
    try {
      _isLoading.value = true;

      // TODO: Verify OTP and complete signup
      // final response = await Supabase.instance.client
      //     .from('pending_signups')
      //     .select()
      //     .eq('email', email)
      //     .eq('otp', otp)
      //     .single();
      //
      // if (response != null) {
      //   // OTP is valid, mark as pending approval
      //   await Supabase.instance.client
      //       .from('pending_signups')
      //       .update({'status': 'pending_approval'})
      //       .eq('email', email);
      //
      //   // Send notification to admin
      //   await _notifyAdminOfNewSignup(email);
      //
      //   return true;
      // }

      // Mock verification
      await Future.delayed(const Duration(seconds: 1));

      _isLoading.value = false;
      return true;
    } catch (e) {
      _isLoading.value = false;
      print('OTP verification error: $e');
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading.value = true;

      // TODO: Send password reset email
      // await Supabase.instance.client.auth.resetPasswordForEmail(email);

      // Mock reset
      await Future.delayed(const Duration(seconds: 1));

      _isLoading.value = false;
      return true;
    } catch (e) {
      _isLoading.value = false;
      print('Password reset error: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // TODO: Supabase sign out
      // await Supabase.instance.client.auth.signOut();

      _isAuthenticated.value = false;
      _currentUser.value = null;

      // Navigate to login
      Get.offAllNamed('/login');
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  // Helper: Generate OTP
  String _generateOTP() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
      6,
      (index) =>
          chars[(DateTime.now().millisecondsSinceEpoch + index) % chars.length],
    ).join();
  }

  // Helper: Send OTP email
  Future<void> _sendOTPEmail(String email, String otp) async {
    // TODO: Implement email sending
    print('Sending OTP $otp to $email');
  }

  // Helper: Notify admin of new signup
  Future<void> _notifyAdminOfNewSignup(String email) async {
    // TODO: Create notification for admin
    print('Notifying admin of new signup: $email');
  }
}
