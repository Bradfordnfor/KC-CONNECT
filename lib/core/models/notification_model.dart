// lib/core/models/notification_model.dart

class NotificationModel {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isRead;
  final String
  type; // 'event', 'resource', 'announcement', 'mentorship', 'system'
  final String? actionUrl; // Route to navigate when tapped
  final Map<String, dynamic>? metadata; // Additional data for the notification

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    this.isRead = false,
    required this.type,
    this.actionUrl,
    this.metadata,
  });

  // Getters for display
  String get displayTitle => title;
  String get displayDescription => description;
  String get formattedTimestamp => _formatTimestamp(timestamp);
  String get typeLabel => _getTypeLabel(type);

  // Get icon for notification type
  String get iconName {
    switch (type.toLowerCase()) {
      case 'event':
        return 'event';
      case 'resource':
        return 'book';
      case 'announcement':
        return 'campaign';
      case 'mentorship':
        return 'people';
      case 'system':
        return 'settings';
      default:
        return 'notifications';
    }
  }

  // Format timestamp
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  // Get type label
  String _getTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'event':
        return 'Event';
      case 'resource':
        return 'Resource';
      case 'announcement':
        return 'Announcement';
      case 'mentorship':
        return 'Mentorship';
      case 'system':
        return 'System';
      default:
        return 'Notification';
    }
  }

  // Copy with method
  NotificationModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? timestamp,
    bool? isRead,
    String? type,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      actionUrl: actionUrl ?? this.actionUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  // Mark as read
  NotificationModel markAsRead() {
    return copyWith(isRead: true);
  }

  // Mark as unread
  NotificationModel markAsUnread() {
    return copyWith(isRead: false);
  }

  // Mock data factory
  factory NotificationModel.mock({
    String? id,
    String? title,
    String? type,
    int? hoursAgo,
    bool? isRead,
  }) {
    final timestamp = DateTime.now().subtract(Duration(hours: hoursAgo ?? 2));

    return NotificationModel(
      id: id ?? 'notif_1',
      title: title ?? 'The STEM Quest is here!!',
      description:
          'Register for the national STEM quest today and get a 30% discount on early bird tickets. Limited spots available!',
      timestamp: timestamp,
      isRead: isRead ?? false,
      type: type ?? 'event',
      actionUrl: '/events',
      metadata: {'eventId': 'event_1', 'discount': 30},
    );
  }

  // Create list of mock notifications
  static List<NotificationModel> mockList() {
    return [
      NotificationModel.mock(
        id: 'notif_1',
        title: 'The STEM Quest is here!!',
        type: 'event',
        hoursAgo: 2,
        isRead: false,
      ),
      NotificationModel.mock(
        id: 'notif_2',
        title: 'New Resource: Mathematics Past Paper',
        type: 'resource',
        hoursAgo: 5,
        isRead: false,
      ),
      NotificationModel.mock(
        id: 'notif_3',
        title: 'Mentorship Request Approved',
        type: 'mentorship',
        hoursAgo: 24,
        isRead: false,
      ),
      NotificationModel(
        id: 'notif_4',
        title: 'Career Workshop Tomorrow',
        description:
            'Don\'t forget! The career development workshop starts tomorrow at 2:00 PM in the main hall.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        type: 'event',
        actionUrl: '/events',
        metadata: {'eventId': 'event_5'},
      ),
      NotificationModel(
        id: 'notif_5',
        title: 'Important: System Maintenance',
        description:
            'The KC Connect platform will undergo scheduled maintenance on Saturday from 2:00 AM to 4:00 AM.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
        type: 'system',
      ),
      NotificationModel(
        id: 'notif_6',
        title: 'Welcome to KC Connect!',
        description:
            'Thanks for joining KC Connect. Explore resources, connect with alumni, and register for exciting events.',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        isRead: true,
        type: 'announcement',
      ),
      NotificationModel(
        id: 'notif_7',
        title: 'New Alumni Joined',
        description:
            'Dr. Grace Tabi, Class of 2019, is now available for mentorship in Medicine and Public Health.',
        timestamp: DateTime.now().subtract(const Duration(days: 4)),
        isRead: true,
        type: 'mentorship',
        actionUrl: '/alumni',
        metadata: {'alumniId': 'alumni_6'},
      ),
    ];
  }

  // Get unread notifications
  static List<NotificationModel> unreadNotifications() {
    return mockList().where((notif) => !notif.isRead).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Get recent notifications (last 7 days)
  static List<NotificationModel> recentNotifications() {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return mockList()
        .where((notif) => notif.timestamp.isAfter(sevenDaysAgo))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Get unread count
  static int unreadCount() {
    return mockList().where((notif) => !notif.isRead).length;
  }

  // For Supabase integration (future)
  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'title': title,
  //     'description': description,
  //     'timestamp': timestamp.toIso8601String(),
  //     'is_read': isRead,
  //     'type': type,
  //     'action_url': actionUrl,
  //     'metadata': metadata,
  //   };
  // }

  // factory NotificationModel.fromJson(Map<String, dynamic> json) {
  //   return NotificationModel(
  //     id: json['id'] as String,
  //     title: json['title'] as String,
  //     description: json['description'] as String,
  //     timestamp: DateTime.parse(json['timestamp'] as String),
  //     isRead: json['is_read'] as bool? ?? false,
  //     type: json['type'] as String,
  //     actionUrl: json['action_url'] as String?,
  //     metadata: json['metadata'] as Map<String, dynamic>?,
  //   );
  // }
}
