import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
import 'package:kc_connect/features/auth/controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminSettingsController extends GetxController {
  final _isLoading = false.obs;
  final _isSaving = false.obs;
  final _subscriptionFee = 1000.0.obs;
  final _maintenanceMode = false.obs;

  bool get isLoading => _isLoading.value;
  bool get isSaving => _isSaving.value;
  double get subscriptionFee => _subscriptionFee.value;
  bool get maintenanceMode => _maintenanceMode.value;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      _isLoading.value = true;

      final data = await Supabase.instance.client
          .from('app_settings')
          .select('key, value')
          .inFilter('key', ['subscription_fee', 'maintenance_mode']);

      for (final row in data) {
        final key = row['key'] as String;
        final value = row['value'];
        if (key == 'subscription_fee') {
          _subscriptionFee.value = (value as num?)?.toDouble() ?? 1000.0;
        } else if (key == 'maintenance_mode') {
          _maintenanceMode.value = (value as bool?) ?? false;
        }
      }

      _isLoading.value = false;
    } catch (e) {
      _isLoading.value = false;
      debugPrint('Settings load error: $e');
    }
  }

  Future<void> updateSubscriptionFee(double fee) async {
    try {
      _isSaving.value = true;
      final userId = Supabase.instance.client.auth.currentUser?.id;

      await Supabase.instance.client.from('app_settings').upsert(
        {
          'key': 'subscription_fee',
          'value': fee,
          'description': 'Monthly subscription fee in XAF',
          'updated_by': userId,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'key',
      );

      _subscriptionFee.value = fee;
      AppSnackbar.success(
        'Saved',
        'Subscription fee updated to XAF ${fee.toStringAsFixed(0)}',
      );
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to update subscription fee');
    } finally {
      _isSaving.value = false;
    }
  }

  Future<void> toggleMaintenanceMode(bool value) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;

      await Supabase.instance.client.from('app_settings').upsert(
        {
          'key': 'maintenance_mode',
          'value': value,
          'description': 'Put app in maintenance mode for all non-admin users',
          'updated_by': userId,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'key',
      );

      _maintenanceMode.value = value;
      AppSnackbar.success(
        value ? 'Maintenance On' : 'Maintenance Off',
        value
            ? 'Non-admin users will see a maintenance screen'
            : 'App is back online for all users',
      );
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to toggle maintenance mode');
    }
  }

  Future<void> changePassword(String newPassword) async {
    try {
      _isSaving.value = true;
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      AppSnackbar.success('Updated', 'Password changed successfully');
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to change password');
    } finally {
      _isSaving.value = false;
    }
  }

  void logout() {
    Get.find<AuthController>().signOut();
  }
}
