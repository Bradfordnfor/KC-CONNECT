import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminAnalyticsController extends GetxController {
  final _isLoading = false.obs;

  // User stats
  final _totalUsers = 0.obs;
  final _usersByRole = <String, int>{}.obs;
  final _recentSignups = 0.obs; // last 7 days

  // Content stats
  final _totalResources = 0.obs;
  final _totalEvents = 0.obs;
  final _totalProducts = 0.obs;
  final _totalDownloads = 0.obs;

  // Revenue & subscriptions
  final _totalRevenue = 0.0.obs;
  final _activeSubscriptions = 0.obs;
  final _pendingOrders = 0.obs;

  // Recent orders
  final _recentOrders = <Map<String, dynamic>>[].obs;

  bool get isLoading => _isLoading.value;
  int get totalUsers => _totalUsers.value;
  Map<String, int> get usersByRole => _usersByRole;
  int get recentSignups => _recentSignups.value;
  int get totalResources => _totalResources.value;
  int get totalEvents => _totalEvents.value;
  int get totalProducts => _totalProducts.value;
  int get totalDownloads => _totalDownloads.value;
  double get totalRevenue => _totalRevenue.value;
  int get activeSubscriptions => _activeSubscriptions.value;
  int get pendingOrders => _pendingOrders.value;
  List<Map<String, dynamic>> get recentOrders => _recentOrders;

  @override
  void onInit() {
    super.onInit();
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    try {
      _isLoading.value = true;

      final sevenDaysAgo =
          DateTime.now().subtract(const Duration(days: 7)).toIso8601String();

      final results = await Future.wait([
        // 0: all active users with role
        Supabase.instance.client
            .from('users')
            .select('role')
            .eq('status', 'active'),
        // 1: new signups in last 7 days
        Supabase.instance.client
            .from('users')
            .select('id')
            .gte('created_at', sevenDaysAgo),
        // 2: resources
        Supabase.instance.client
            .from('resources')
            .select('id')
            .eq('status', 'active'),
        // 3: events
        Supabase.instance.client
            .from('events')
            .select('id')
            .neq('status', 'cancelled'),
        // 4: products
        Supabase.instance.client
            .from('products')
            .select('id')
            .eq('status', 'active'),
        // 5: total downloads
        Supabase.instance.client.from('downloads').select('id'),
        // 6: paid orders (all time revenue)
        Supabase.instance.client
            .from('orders')
            .select('total')
            .eq('payment_status', 'paid'),
        // 7: active premium subscriptions
        Supabase.instance.client
            .from('users')
            .select('id')
            .eq('subscription_status', 'premium'),
        // 8: pending orders
        Supabase.instance.client
            .from('orders')
            .select('id')
            .eq('status', 'pending'),
        // 9: recent 8 orders
        Supabase.instance.client
            .from('orders')
            .select('order_number, total, payment_status, status, created_at')
            .order('created_at', ascending: false)
            .limit(8),
      ]);

      // User breakdown
      final roleMap = <String, int>{
        'student': 0,
        'alumni': 0,
        'staff': 0,
        'admin': 0,
      };
      for (final user in results[0] as List) {
        final role = user['role'] as String? ?? 'student';
        roleMap[role] = (roleMap[role] ?? 0) + 1;
      }
      _usersByRole.value = roleMap;
      _totalUsers.value = roleMap.values.fold(0, (a, b) => a + b);

      _recentSignups.value = (results[1] as List).length;
      _totalResources.value = (results[2] as List).length;
      _totalEvents.value = (results[3] as List).length;
      _totalProducts.value = (results[4] as List).length;
      _totalDownloads.value = (results[5] as List).length;

      double revenue = 0.0;
      for (final order in results[6] as List) {
        revenue += (order['total'] as num?)?.toDouble() ?? 0.0;
      }
      _totalRevenue.value = revenue;

      _activeSubscriptions.value = (results[7] as List).length;
      _pendingOrders.value = (results[8] as List).length;
      _recentOrders.value =
          (results[9] as List).cast<Map<String, dynamic>>();

      _isLoading.value = false;
    } catch (e) {
      _isLoading.value = false;
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> refresh() async => loadAnalytics();
}
