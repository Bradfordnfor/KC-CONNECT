// lib/features/notifications/controllers/notifications_controller.dart
import 'package:get/get.dart';
import 'package:kc_connect/core/models/notification_model.dart';
import 'package:kc_connect/core/routes/app_routes.dart';

class NotificationsController extends GetxController {
  // Reactive state
  final _allNotifications = <NotificationModel>[].obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;

  // Getters
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

  // Load notifications
  Future<void> loadNotifications() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Load mock data (replace with Supabase real-time later)
      _allNotifications.value = NotificationModel.mockList();

      // Sort by timestamp (newest first)
      _allNotifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      _isLoading.value = false;
    } catch (e) {
      _errorMessage.value = 'Failed to load notifications: ${e.toString()}';
      _isLoading.value = false;
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final index = _allNotifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final notification = _allNotifications[index];

        if (!notification.isRead) {
          // Simulate API call
          await Future.delayed(const Duration(milliseconds: 200));

          // Update notification
          _allNotifications[index] = notification.markAsRead();
        }
      }
    } catch (e) {
      // Silent fail for marking as read
    }
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));

      // Update all notifications
      _allNotifications.value = _allNotifications
          .map((n) => n.isRead ? n : n.markAsRead())
          .toList();

      Get.snackbar(
        'Success',
        'All notifications marked as read',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to mark notifications as read',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));

      // Remove notification
      _allNotifications.removeWhere((n) => n.id == notificationId);

      Get.snackbar(
        'Deleted',
        'Notification deleted',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete notification',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      if (_allNotifications.isEmpty) {
        Get.snackbar(
          'Info',
          'No notifications to clear',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));

      // Clear all
      _allNotifications.clear();

      Get.snackbar(
        'Cleared',
        'All notifications cleared',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clear notifications',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Handle notification tap
  void handleNotificationTap(NotificationModel notification) {
    // Mark as read
    markAsRead(notification.id);

    // Navigate if action URL exists
    if (notification.actionUrl != null) {
      // Extract route and navigate
      final route = notification.actionUrl!;

      // Pass metadata as arguments if available
      if (notification.metadata != null) {
        Get.toNamed(route, arguments: notification.metadata);
      } else {
        Get.toNamed(route);
      }
    } else {
      // Just show the notification detail
      Get.snackbar(
        notification.title,
        notification.description,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Add new notification (for testing/demo)
  void addNotification(NotificationModel notification) {
    _allNotifications.insert(0, notification);
  }

  // Simulate receiving a new notification
  void simulateNewNotification() {
    final newNotification = NotificationModel(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: 'New Event: Study Session',
      description:
          'Join us for a group study session this Saturday at 3:00 PM.',
      timestamp: DateTime.now(),
      isRead: false,
      type: 'event',
      actionUrl: AppRoutes.events,
    );

    addNotification(newNotification);

    Get.snackbar(
      '🔔 New Notification',
      newNotification.title,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      onTap: (_) => handleNotificationTap(newNotification),
    );
  }

  // Get notifications by type
  List<NotificationModel> getNotificationsByType(String type) {
    return _allNotifications.where((n) => n.type == type).toList();
  }

  // Get recent notifications (last 24 hours)
  List<NotificationModel> getRecentNotifications() {
    final yesterday = DateTime.now().subtract(const Duration(hours: 24));
    return _allNotifications
        .where((n) => n.timestamp.isAfter(yesterday))
        .toList();
  }

  // Refresh notifications
  Future<void> refreshNotifications() async {
    await loadNotifications();
  }

  // Get notification statistics
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
