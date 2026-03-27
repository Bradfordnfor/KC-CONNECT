// lib/features/notifications/controllers/notifications_controller.dart
import 'package:get/get.dart';
import 'package:kc_connect/core/models/notification_model.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsController extends GetxController {
  final _allNotifications = <NotificationModel>[].obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;

  List<NotificationModel> get allNotifications => _allNotifications;
  List<NotificationModel> get unreadNotifications =>
      _allNotifications.where((n) => !n.isRead).toList();
  List<NotificationModel> get readNotifications =>
      _allNotifications.where((n) => n.isRead).toList();
  int get unreadCount => unreadNotifications.length;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  bool get hasNotifications => _allNotifications.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        _allNotifications.clear();
        _isLoading.value = false;
        return;
      }

      final response = await Supabase.instance.client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _allNotifications.value = (response as List)
          .map(
            (n) => NotificationModel(
              id: n['id'],
              title: n['title'] ?? '',
              description: n['message'] ?? '',
              timestamp:
                  DateTime.tryParse(n['created_at'] ?? '') ?? DateTime.now(),
              isRead: n['is_read'] ?? false,
              type: n['type'] ?? 'system',
              actionUrl: n['action_url'],
              metadata: n['metadata'],
            ),
          )
          .toList();

      _isLoading.value = false;
    } catch (e) {
      _errorMessage.value = 'Failed to load notifications';
      _isLoading.value = false;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final index =
          _allNotifications.indexWhere((n) => n.id == notificationId);
      if (index != -1 && !_allNotifications[index].isRead) {
        await Supabase.instance.client
            .from('notifications')
            .update({'is_read': true, 'read_at': DateTime.now().toIso8601String()})
            .eq('id', notificationId);

        _allNotifications[index] = _allNotifications[index].markAsRead();
      }
    } catch (e) {
      // Silent fail for mark-as-read
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      await Supabase.instance.client
          .from('notifications')
          .update({'is_read': true, 'read_at': DateTime.now().toIso8601String()})
          .eq('user_id', userId)
          .eq('is_read', false);

      _allNotifications.value =
          _allNotifications.map((n) => n.isRead ? n : n.markAsRead()).toList();

      AppSnackbar.success('Done', 'All notifications marked as read');
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to mark notifications as read');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await Supabase.instance.client
          .from('notifications')
          .delete()
          .eq('id', notificationId);

      _allNotifications.removeWhere((n) => n.id == notificationId);
      AppSnackbar.info('Deleted', 'Notification deleted');
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to delete notification');
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      if (_allNotifications.isEmpty) {
        AppSnackbar.info('Info', 'No notifications to clear');
        return;
      }

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      await Supabase.instance.client
          .from('notifications')
          .delete()
          .eq('user_id', userId);

      _allNotifications.clear();
      AppSnackbar.info('Cleared', 'All notifications cleared');
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to clear notifications');
    }
  }

  void handleNotificationTap(NotificationModel notification) {
    markAsRead(notification.id);

    if (notification.actionUrl != null) {
      if (notification.metadata != null) {
        Get.toNamed(notification.actionUrl!, arguments: notification.metadata);
      } else {
        Get.toNamed(notification.actionUrl!);
      }
    }
  }

  Future<void> refreshNotifications() => loadNotifications();

  List<NotificationModel> getNotificationsByType(String type) =>
      _allNotifications.where((n) => n.type == type).toList();

  List<NotificationModel> getRecentNotifications() {
    final yesterday = DateTime.now().subtract(const Duration(hours: 24));
    return _allNotifications
        .where((n) => n.timestamp.isAfter(yesterday))
        .toList();
  }

  Map<String, int> getStatistics() {
    return {
      'total': _allNotifications.length,
      'unread': unreadCount,
      'read': readNotifications.length,
      'event': getNotificationsByType('event').length,
      'resource': getNotificationsByType('resource').length,
      'announcement': getNotificationsByType('announcement').length,
    };
  }
}
