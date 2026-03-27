// lib/features/notifications/presentation/screens/news_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/navigation/main_navigation.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<Map<String, dynamic>> notifications = [
    {
      'id': '1',
      'title': 'The STEM is here!!',
      'description':
          'Register for the national STEM quest today and get a 30% discount on first registration',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'isRead': false,
    },
    {
      'id': '2',
      'title': 'The STEM is here!!',
      'description':
          'Register for the national STEM quest today and get a 30% discount on ...',
      'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
      'isRead': false,
    },
    {
      'id': '3',
      'title': 'The STEM is here!!',
      'description':
          'Register for the national STEM quest today and get a 30% discount on ...',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': false,
    },
    {
      'id': '4',
      'title': 'The STEM is here!!',
      'description':
          'Register for the national STEM quest today and get a 30% discount on ...',
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      'isRead': true,
    },
    {
      'id': '5',
      'title': 'The STEM is here!!',
      'description':
          'Register for the national STEM quest today and get a 30% discount on ...',
      'timestamp': DateTime.now().subtract(const Duration(days: 3)),
      'isRead': true,
    },
  ];

  void _clearAllNotifications() {
    setState(() {
      notifications.clear();
    });
  }

  void _markAsRead(String id) {
    setState(() {
      final index = notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        notifications[index]['isRead'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: MainNavigation.buildSecondaryAppBar(
        context,
        title: 'Notifications',
      ),
      body: Column(
        children: [
          _buildClearButton(),
          Expanded(
            child: notifications.isEmpty
                ? _buildEmptyState()
                : _buildNotificationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildClearButton() {
    return Container(
      color: AppColors.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.delete_outline, color: AppColors.red, size: 20),
          const SizedBox(width: 4),
          TextButton(
            onPressed: notifications.isEmpty ? null : _clearAllNotifications,
            child: Text(
              'Clear',
              style: AppTextStyles.body.copyWith(
                color: notifications.isEmpty ? Colors.grey : AppColors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['isRead'] as bool;

    return GestureDetector(
      onTap: () {
        _markAsRead(notification['id']);
        // Show full notification details
        _showNotificationDetail(notification);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? AppColors.white.withValues(alpha: 0.5) : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRead
                ? AppColors.backgroundColor
                : AppColors.blue.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bell Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isRead
                    ? AppColors.blue.withValues(alpha: 0.1)
                    : AppColors.blue.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.notifications, color: AppColors.blue, size: 20),
            ),

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    notification['title'] as String,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Description
                  Text(
                    notification['description'] as String,
                    style: AppTextStyles.body.copyWith(
                      color: Colors.grey[700],
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Timestamp
                  Text(
                    _formatTimestamp(notification['timestamp'] as DateTime),
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Unread indicator
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6, left: 8),
                decoration: const BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showNotificationDetail(Map<String, dynamic> notification) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.blue.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications,
                        color: AppColors.blue,
                        size: 22,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  notification['title'] as String,
                  style: AppTextStyles.subHeading.copyWith(
                    color: AppColors.blue,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  notification['description'] as String,
                  style: AppTextStyles.body.copyWith(
                    color: Colors.grey[700],
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _formatTimestamp(notification['timestamp'] as DateTime),
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 50,
              color: AppColors.blue.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Notifications',
            style: AppTextStyles.subHeading.copyWith(color: AppColors.blue),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
