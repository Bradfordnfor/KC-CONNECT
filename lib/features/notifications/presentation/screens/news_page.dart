// lib/features/notifications/presentation/screens/news_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/models/notification_model.dart';
import 'package:kc_connect/core/navigation/main_navigation.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/features/notifications/controllers/notifications_controller.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationsController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: MainNavigation.buildSecondaryAppBar(
        context,
        title: 'Notifications',
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.blue),
          );
        }
        return Column(
          children: [
            _buildToolbar(controller),
            Expanded(
              child: controller.allNotifications.isEmpty
                  ? _buildEmptyState()
                  : _buildList(controller),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildToolbar(NotificationsController controller) {
    return Container(
      color: AppColors.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Mark all as read
          Obx(() {
            final hasUnread = controller.unreadCount > 0;
            return TextButton.icon(
              onPressed: hasUnread ? controller.markAllAsRead : null,
              icon: Icon(
                Icons.done_all,
                size: 18,
                color: hasUnread ? AppColors.blue : Colors.grey,
              ),
              label: Text(
                'Mark all read',
                style: AppTextStyles.body.copyWith(
                  color: hasUnread ? AppColors.blue : Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }),

          // Clear all
          Obx(() {
            final hasAny = controller.hasNotifications;
            return TextButton.icon(
              onPressed: hasAny ? controller.clearAllNotifications : null,
              icon: Icon(
                Icons.delete_outline,
                size: 18,
                color: hasAny ? AppColors.red : Colors.grey,
              ),
              label: Text(
                'Clear all',
                style: AppTextStyles.body.copyWith(
                  color: hasAny ? AppColors.red : Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildList(NotificationsController controller) {
    return RefreshIndicator(
      color: AppColors.blue,
      onRefresh: controller.refreshNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: controller.allNotifications.length,
        itemBuilder: (context, index) {
          final notification = controller.allNotifications[index];
          return _buildNotificationCard(context, notification, controller);
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel notification,
    NotificationsController controller,
  ) {
    final isRead = notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => controller.deleteNotification(notification.id),
      child: GestureDetector(
        onTap: () {
          controller.handleNotificationTap(notification);
          _showNotificationDetail(context, notification, controller);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isRead ? AppColors.white.withValues(alpha: 0.5) : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isRead
                  ? AppColors.backgroundColor
                  : AppColors.blue.withValues(alpha: 0.2),
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
              // Type icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isRead
                      ? AppColors.blue.withValues(alpha: 0.1)
                      : AppColors.blue.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _iconForType(notification.type),
                  color: AppColors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.description,
                      style: AppTextStyles.body.copyWith(
                        color: Colors.grey[700],
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.formattedTimestamp,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                    if (notification.actionType == 'mentorship_request' &&
                        notification.actionId != null)
                      _buildMentorshipActions(
                          notification, controller, context),
                  ],
                ),
              ),
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
      ),
    );
  }

  Widget _buildMentorshipActions(
    NotificationModel notification,
    NotificationsController controller,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => controller.rejectMentorshipRequest(
                notification.id,
                notification.actionId!,
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.red),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Decline',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () => controller.acceptMentorshipRequest(
                notification.id,
                notification.actionId!,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Accept',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationDetail(
    BuildContext context,
    NotificationModel notification,
    NotificationsController controller,
  ) {
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
                        _iconForType(notification.type),
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
                  notification.title,
                  style: AppTextStyles.subHeading.copyWith(
                    color: AppColors.blue,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  notification.description,
                  style: AppTextStyles.body.copyWith(
                    color: Colors.grey[700],
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  notification.formattedTimestamp,
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

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'event':
        return Icons.event;
      case 'resource':
        return Icons.menu_book_outlined;
      case 'announcement':
        return Icons.campaign_outlined;
      case 'mentorship':
        return Icons.people_outline;
      case 'system':
        return Icons.settings_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }
}
