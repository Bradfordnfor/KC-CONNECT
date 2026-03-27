// lib/controllers/admin/admin_broadcast_controller.dart
import 'package:get/get.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminBroadcastController extends GetxController {
  final _selectedAudiences = <String>[].obs;
  final _isSending = false.obs;

  List<String> get selectedAudiences => _selectedAudiences;
  bool get isSending => _isSending.value;

  final audiences = ['Everyone', 'Students', 'Alumni', 'Staff', 'Admin'];

  void toggleAudience(String audience) {
    if (audience == 'Everyone') {
      if (_selectedAudiences.contains('Everyone')) {
        _selectedAudiences.clear();
      } else {
        _selectedAudiences.value = ['Everyone'];
      }
    } else {
      _selectedAudiences.remove('Everyone');
      if (_selectedAudiences.contains(audience)) {
        _selectedAudiences.remove(audience);
      } else {
        _selectedAudiences.add(audience);
      }
    }
  }

  bool isAudienceSelected(String audience) =>
      _selectedAudiences.contains(audience);

  Future<void> sendBroadcast({
    required String title,
    required String message,
  }) async {
    try {
      if (_selectedAudiences.isEmpty) {
        AppSnackbar.error('No Audience', 'Please select at least one audience');
        return;
      }

      _isSending.value = true;

      // Determine target roles
      final List<String> targetRoles;
      if (_selectedAudiences.contains('Everyone')) {
        targetRoles = ['student', 'alumni', 'staff', 'admin'];
      } else {
        targetRoles = _selectedAudiences.map((a) => a.toLowerCase()).toList();
      }

      // Fetch active user IDs for target roles
      final usersResponse = await Supabase.instance.client
          .from('users')
          .select('id')
          .inFilter('role', targetRoles)
          .eq('status', 'active');

      final userIds =
          (usersResponse as List).map((u) => u['id'] as String).toList();

      if (userIds.isEmpty) {
        _isSending.value = false;
        AppSnackbar.error('No Users', 'No active users found for selected audience');
        return;
      }

      // Insert one notification per user
      final now = DateTime.now().toIso8601String();
      final notifications = userIds
          .map(
            (uid) => {
              'user_id': uid,
              'title': title,
              'message': message,
              'type': 'announcement',
              'priority': 'normal',
              'is_read': false,
              'created_at': now,
            },
          )
          .toList();

      await Supabase.instance.client.from('notifications').insert(notifications);

      _isSending.value = false;
      _selectedAudiences.clear();

      AppSnackbar.success(
        'Broadcast Sent',
        'Announcement sent to ${userIds.length} user${userIds.length == 1 ? '' : 's'}',
      );

      Get.back();
    } catch (e) {
      _isSending.value = false;
      AppSnackbar.error('Error', 'Failed to send broadcast');
    }
  }

  void resetSelections() => _selectedAudiences.clear();
}
