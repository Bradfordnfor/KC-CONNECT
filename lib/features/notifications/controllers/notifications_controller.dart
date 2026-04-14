// lib/features/notifications/controllers/notifications_controller.dart
import 'package:get/get.dart';
import 'package:kc_connect/core/models/notification_model.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
import 'package:kc_connect/features/auth/controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsController extends GetxController {
  final _allNotifications = <NotificationModel>[].obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  RealtimeChannel? _channel;

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
    _subscribeToRealtime();
  }

  void _subscribeToRealtime() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    _channel = Supabase.instance.client
        .channel('notifications_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final n = payload.newRecord;
            _allNotifications.insert(
              0,
              NotificationModel(
                id: n['id'],
                title: n['title'] ?? '',
                description: n['message'] ?? '',
                timestamp:
                    DateTime.tryParse(n['created_at'] ?? '') ?? DateTime.now(),
                isRead: n['is_read'] ?? false,
                type: n['type'] ?? 'system',
                actionUrl: n['action_url'],
                metadata: n['metadata'] as Map<String, dynamic>?,
                actionId: n['action_id'],
                actionType: n['action_type'],
              ),
            );
          },
        )
        .subscribe();
  }

  @override
  void onClose() {
    if (_channel != null) {
      Supabase.instance.client.removeChannel(_channel!);
    }
    super.onClose();
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
              actionId: n['action_id'],
              actionType: n['action_type'],
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

  // ─── OTP approval actions (admin only) ──────────────────────────────────

  Future<void> approveSignup(String notificationId, String signupId) async {
    try {
      // Use a DB RPC (SECURITY DEFINER) so this works regardless of edge
      // function deployment state or RLS policies on pending_signups.
      final result = await Supabase.instance.client
          .rpc('approve_signup', params: {'p_signup_id': signupId});

      final data = result as Map<String, dynamic>?;
      if (data == null || data['success'] != true) {
        AppSnackbar.error('Error', 'Failed to approve signup: ${data?['error'] ?? 'unknown'}');
        return;
      }

      // Non-fatal: send OTP email. If Resend key isn't set the approval still
      // succeeds — admin can share the OTP from the notify-admin-signup email.
      try {
        await Supabase.instance.client.functions.invoke('send-otp-email', body: {
          'email': data['email'],
          'name': data['name'],
          'otp': data['otp'],
          'type': 'otp',
        });
      } catch (_) {}

      await _markOTPHandled(notificationId);
      AppSnackbar.success('Approved', 'OTP sent to the applicant\'s email.');
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to approve signup.');
    }
  }

  Future<void> rejectSignupFromNotification(
      String notificationId, String signupId, String reason) async {
    try {
      final meta = _allNotifications
          .firstWhereOrNull((n) => n.id == notificationId)
          ?.metadata;

      await Supabase.instance.client
          .from('pending_signups')
          .update({'is_active': false}).eq('id', signupId);

      if (meta != null) {
        await Supabase.instance.client.functions.invoke('send-otp-email', body: {
          'email': meta['applicant_email'],
          'name': meta['applicant_name'],
          'type': 'rejection',
          'reason': reason,
        });
      }
      await _markOTPHandled(notificationId);
      AppSnackbar.info('Rejected', 'Applicant has been notified.');
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to reject signup.');
    }
  }

  /// Marks an OTP approval notification as handled — sets is_read and changes
  /// action_type so the Approve/Reject buttons no longer render.
  Future<void> _markOTPHandled(String notificationId) async {
    await Supabase.instance.client
        .from('notifications')
        .update({
          'is_read': true,
          'read_at': DateTime.now().toIso8601String(),
          'action_type': 'otp_handled',
        })
        .eq('id', notificationId);

    final index = _allNotifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _allNotifications[index] = _allNotifications[index]
          .copyWith(isRead: true, actionType: 'otp_handled');
    }
  }

  Future<void> acceptMentorshipRequest(
      String notificationId, String requestId) async {
    try {
      // Get student info from the request
      final req = await Supabase.instance.client
          .from('mentorship_requests')
          .select('student_id')
          .eq('id', requestId)
          .single();

      final studentId = req['student_id'] as String;

      // Accept this request
      await Supabase.instance.client
          .from('mentorship_requests')
          .update({'status': 'accepted'})
          .eq('id', requestId);

      // Get alumni (current user) info
      final me = Get.find<AuthController>().currentUser;
      final mentorName = me?['full_name'] ?? 'Your mentor';
      final mentorEmail = me?['email'] ?? '';

      // Get the student's name for notifications to other alumni
      final studentData = await Supabase.instance.client
          .from('users')
          .select('full_name')
          .eq('id', studentId)
          .single();
      final studentName = studentData['full_name'] as String? ?? 'The student';

      // Cancel all OTHER pending requests this student sent to other alumni,
      // and notify each of those alumni so they know why.
      final otherPending = await Supabase.instance.client
          .from('mentorship_requests')
          .select('id, mentor_id')
          .eq('student_id', studentId)
          .eq('status', 'pending')
          .neq('id', requestId);

      if ((otherPending as List).isNotEmpty) {
        final otherIds = otherPending.map((r) => r['id'] as String).toList();

        // Mark them all cancelled
        await Supabase.instance.client
            .from('mentorship_requests')
            .update({'status': 'cancelled'})
            .inFilter('id', otherIds);

        // Notify each of the other alumni
        final notifications = otherPending.map((r) => {
          'user_id': r['mentor_id'] as String,
          'title': 'Mentorship Request Withdrawn',
          'message':
              '$studentName has found a mentor and their request to you has been automatically withdrawn.',
          'type': 'mentorship',
          'action_type': 'mentorship_withdrawn',
          'is_read': false,
          'created_at': DateTime.now().toIso8601String(),
        }).toList();

        await Supabase.instance.client.from('notifications').insert(notifications);
      }

      // Notify the student that their request was accepted
      await Supabase.instance.client.from('notifications').insert({
        'user_id': studentId,
        'title': 'Mentorship Request Accepted!',
        'message':
            '$mentorName accepted your request. Reach them at: $mentorEmail',
        'type': 'mentorship',
        'action_type': 'mentorship_accepted',
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      await _markMentorshipHandled(notificationId,
          actionType: 'mentorship_accepted');
      AppSnackbar.success('Accepted', 'Mentorship request accepted.');
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to accept request.');
    }
  }

  Future<void> rejectMentorshipRequest(
      String notificationId, String requestId) async {
    try {
      final req = await Supabase.instance.client
          .from('mentorship_requests')
          .select('student_id')
          .eq('id', requestId)
          .single();

      final studentId = req['student_id'] as String;

      await Supabase.instance.client
          .from('mentorship_requests')
          .update({'status': 'declined'})
          .eq('id', requestId);

      final me = Get.find<AuthController>().currentUser;
      final mentorName = me?['full_name'] ?? 'The alumni';

      await Supabase.instance.client.from('notifications').insert({
        'user_id': studentId,
        'title': 'Mentorship Request Declined',
        'message': '$mentorName is unable to take on new mentees at this time.',
        'type': 'mentorship',
        'action_type': 'mentorship_rejected',
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      await _markMentorshipHandled(notificationId);
      AppSnackbar.info('Done', 'Mentorship request declined.');
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to decline request.');
    }
  }

  /// Marks a mentorship notification as handled — sets is_read and changes
  /// action_type so the correct buttons render (or stop rendering) in the modal.
  Future<void> _markMentorshipHandled(String notificationId,
      {String actionType = 'mentorship_handled'}) async {
    await Supabase.instance.client
        .from('notifications')
        .update({
          'is_read': true,
          'read_at': DateTime.now().toIso8601String(),
          'action_type': actionType,
        })
        .eq('id', notificationId);

    final index = _allNotifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _allNotifications[index] = _allNotifications[index]
          .copyWith(isRead: true, actionType: actionType);
    }
  }

  // Called when the alumni taps "End Mentorship" from their notification.
  Future<void> endMentorshipFromAlumni(
      String notificationId, String requestId) async {
    try {
      final req = await Supabase.instance.client
          .from('mentorship_requests')
          .select('student_id')
          .eq('id', requestId)
          .single();
      final studentId = req['student_id'] as String;

      await Supabase.instance.client
          .from('mentorship_requests')
          .update({'status': 'ended'})
          .eq('id', requestId);

      final me = Get.find<AuthController>().currentUser;
      final mentorName = me?['full_name'] as String? ?? 'Your mentor';

      await Supabase.instance.client.from('notifications').insert({
        'user_id': studentId,
        'title': 'Mentorship Ended',
        'message':
            '$mentorName has ended their mentorship with you. You can now request mentorship from other alumni.',
        'type': 'mentorship',
        'action_type': 'mentorship_ended',
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      await _markMentorshipHandled(notificationId,
          actionType: 'mentorship_ended');
      AppSnackbar.info('Ended', 'Mentorship has been ended.');
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to end mentorship.');
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
