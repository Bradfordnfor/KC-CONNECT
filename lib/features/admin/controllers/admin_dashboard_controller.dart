import 'package:get/get.dart';
// import 'package:supabase_flutter/supabase_flutter.dart'; // Uncomment when ready

class AdminDashboardController extends GetxController {
  // Reactive state
  final _isLoading = false.obs;
  final _totalUsers = 0.obs;
  final _studentCount = 0.obs;
  final _alumniCount = 0.obs;
  final _staffCount = 0.obs;
  final _adminCount = 0.obs;
  final _totalResources = 0.obs;
  final _totalEvents = 0.obs;
  final _totalProducts = 0.obs;
  final _pendingOTPs = 0.obs;
  final _monthlyRevenue = 0.0.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  int get totalUsers => _totalUsers.value;
  int get studentCount => _studentCount.value;
  int get alumniCount => _alumniCount.value;
  int get staffCount => _staffCount.value;
  int get adminCount => _adminCount.value;
  int get totalResources => _totalResources.value;
  int get totalEvents => _totalEvents.value;
  int get totalProducts => _totalProducts.value;
  int get pendingOTPs => _pendingOTPs.value;
  double get monthlyRevenue => _monthlyRevenue.value;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  // Load dashboard metrics
  Future<void> loadDashboardData() async {
    try {
      _isLoading.value = true;

      // TODO: Replace with actual Supabase queries
      // final usersData = await Supabase.instance.client
      //     .from('users')
      //     .select('role')
      //     .execute();

      // Mock data for now
      await Future.delayed(const Duration(milliseconds: 500));

      _studentCount.value = 850;
      _alumniCount.value = 320;
      _staffCount.value = 45;
      _adminCount.value = 5;
      _totalUsers.value =
          _studentCount.value +
          _alumniCount.value +
          _staffCount.value +
          _adminCount.value;

      _totalResources.value = 156;
      _totalEvents.value = 23;
      _totalProducts.value = 12;
      _pendingOTPs.value = 3;
      _monthlyRevenue.value = 245000.0;

      _isLoading.value = false;
    } catch (e) {
      _isLoading.value = false;
      print('Error loading dashboard data: $e');
    }
  }

  // Refresh dashboard
  Future<void> refreshDashboard() async {
    await loadDashboardData();
  }

  // Get user distribution
  Map<String, int> getUserDistribution() {
    return {
      'Students': _studentCount.value,
      'Alumni': _alumniCount.value,
      'Staff': _staffCount.value,
      'Admin': _adminCount.value,
    };
  }
}
