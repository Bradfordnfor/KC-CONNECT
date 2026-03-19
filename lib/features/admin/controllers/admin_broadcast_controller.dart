// lib/controllers/admin/admin_broadcast_controller.dart
import 'package:get/get.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
// import 'package:supabase_flutter/supabase_flutter.dart'; // Uncomment when ready

class AdminBroadcastController extends GetxController {
  final _selectedAudiences = <String>[].obs;
  final _isSending = false.obs;

  List<String> get selectedAudiences => _selectedAudiences;
  bool get isSending => _isSending.value;

  final audiences = ['Everyone', 'Students', 'Alumni', 'Staff', 'Admin'];

  // Toggle audience selection
  void toggleAudience(String audience) {
    if (audience == 'Everyone') {
      if (_selectedAudiences.contains('Everyone')) {
        // Deselect everyone
        _selectedAudiences.clear();
      } else {
        // Select everyone
        _selectedAudiences.value = ['Everyone'];
      }
    } else {
      // Remove "Everyone" if selecting individual
      _selectedAudiences.remove('Everyone');

      if (_selectedAudiences.contains(audience)) {
        _selectedAudiences.remove(audience);
      } else {
        _selectedAudiences.add(audience);
      }
    }
  }

  // Check if audience is selected
  bool isAudienceSelected(String audience) {
    return _selectedAudiences.contains(audience);
  }

  // Send broadcast
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
      List<String> targetRoles = [];
      if (_selectedAudiences.contains('Everyone')) {
        targetRoles = ['student', 'alumni', 'staff', 'admin'];
      } else {
        targetRoles = _selectedAudiences.map((a) => a.toLowerCase()).toList();
      }

      // TODO: Insert notifications for target users
      // await Supabase.instance.client.from('notifications').insert(
      //   targetRoles.map((role) => {
      //     'title': title,
      //     'message': message,
      //     'type': 'announcement',
      //     'target_role': role,
      //     'created_by': currentAdminId,
      //   }).toList(),
      // );

      // Mock send
      await Future.delayed(const Duration(seconds: 1));

      _isSending.value = false;

      // Reset selection
      _selectedAudiences.clear();

      AppSnackbar.success(
        'Broadcast Sent',
        'Announcement sent to ${targetRoles.join(", ")}',
      );

      // Close modal
      Get.back();
    } catch (e) {
      _isSending.value = false;
      AppSnackbar.error('Error', 'Failed to send broadcast');
    }
  }

  // Reset selections
  void resetSelections() {
    _selectedAudiences.clear();
  }
}
