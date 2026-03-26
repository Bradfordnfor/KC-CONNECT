import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/models/notification_model.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/features/notifications/controllers/notifications_controller.dart';

class AdminNotificationsPage extends StatelessWidget {
  const AdminNotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NotificationsController notificationsController = Get.put(
      NotificationsController(),
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.blue),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Admin Notifications',
          style: AppTextStyles.subHeading.copyWith(
            color: AppColors.blue,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(
            () => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications, color: AppColors.blue),
                  onPressed: () {},
                ),
                if (notificationsController.unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${notificationsController.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.done_all, color: AppColors.blue),
            onPressed: () {
              notificationsController.markAllAsRead();
            },
          ),
        ],
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Obx(
        () => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: notificationsController.allNotifications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final n = notificationsController.allNotifications[index];
            return GestureDetector(
              onTap: () async {
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      n.title,
                      style: AppTextStyles.subHeading.copyWith(
                        color: AppColors.blue,
                      ),
                    ),
                    content: Text(n.description, style: AppTextStyles.body),
                    actions: [
                      TextButton(
                        onPressed: () {
                          notificationsController.markAsRead(n.id);
                          Navigator.pop(context);
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
                notificationsController.markAsRead(n.id);
              },
              child: _buildNotificationCard(n),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel n) {
    IconData iconData;
    switch (n.iconName) {
      case 'event':
        iconData = Icons.event;
        break;
      case 'book':
        iconData = Icons.book;
        break;
      case 'campaign':
        iconData = Icons.campaign;
        break;
      case 'people':
        iconData = Icons.people;
        break;
      case 'settings':
        iconData = Icons.settings;
        break;
      default:
        iconData = Icons.notifications;
    }
    final isUnread = !n.isRead;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? AppColors.blue.withOpacity(0.05) : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnread
              ? AppColors.blue.withOpacity(0.2)
              : AppColors.backgroundColor,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(iconData, color: AppColors.blue, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        n.displayTitle,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.blue,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  n.displayDescription,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  n.formattedTimestamp,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textLight,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
