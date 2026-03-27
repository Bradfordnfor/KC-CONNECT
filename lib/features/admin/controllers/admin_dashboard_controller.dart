import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboardController extends GetxController {
  final _isLoading = false.obs;
  final _totalUsers = 0.obs;
  final _studentCount = 0.obs;
  final _alumniCount = 0.obs;
  final _staffCount = 0.obs;
  final _adminCount = 0.obs;
  final _totalResources = 0.obs;
  final _totalEvents = 0.obs;
  final _totalProducts = 0.obs;
  final _pendingSignups = 0.obs;
  final _monthlyRevenue = 0.0.obs;

  bool get isLoading => _isLoading.value;
  int get totalUsers => _totalUsers.value;
  int get studentCount => _studentCount.value;
  int get alumniCount => _alumniCount.value;
  int get staffCount => _staffCount.value;
  int get adminCount => _adminCount.value;
  int get totalResources => _totalResources.value;
  int get totalEvents => _totalEvents.value;
  int get totalProducts => _totalProducts.value;
  int get pendingOTPs => _pendingSignups.value;
  double get monthlyRevenue => _monthlyRevenue.value;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      _isLoading.value = true;

      final results = await Future.wait([
        Supabase.instance.client.from('users').select('role').eq('status', 'active'),
        Supabase.instance.client.from('resources').select('id').eq('status', 'active'),
        Supabase.instance.client.from('events').select('id').neq('status', 'cancelled'),
        Supabase.instance.client.from('products').select('id').eq('status', 'active'),
        Supabase.instance.client
            .from('pending_signups')
            .select('id')
            .eq('is_active', true),
        Supabase.instance.client
            .from('orders')
            .select('total')
            .eq('payment_status', 'paid'),
      ]);

      int student = 0, alumni = 0, staff = 0, admin = 0;
      for (final user in results[0] as List) {
        switch (user['role']) {
          case 'student': student++; break;
          case 'alumni': alumni++; break;
          case 'staff': staff++; break;
          case 'admin': admin++; break;
        }
      }
      _studentCount.value = student;
      _alumniCount.value = alumni;
      _staffCount.value = staff;
      _adminCount.value = admin;
      _totalUsers.value = student + alumni + staff + admin;

      _totalResources.value = (results[1] as List).length;
      _totalEvents.value = (results[2] as List).length;
      _totalProducts.value = (results[3] as List).length;
      _pendingSignups.value = (results[4] as List).length;

      double revenue = 0.0;
      for (final order in results[5] as List) {
        revenue += (order['total'] as num?)?.toDouble() ?? 0.0;
      }
      _monthlyRevenue.value = revenue;

      _isLoading.value = false;
    } catch (e) {
      _isLoading.value = false;
      print('Error loading dashboard data: $e');
    }
  }

  Future<void> refreshDashboard() => loadDashboardData();
}
