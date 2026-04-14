// lib/features/notifications/presentation/screens/news_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/models/notification_model.dart';
import 'package:kc_connect/core/navigation/main_navigation.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/features/notifications/controllers/notifications_controller.dart';
import 'package:kc_connect/features/payment/presentation/widgets/subscription_payment_modal.dart';

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
          controller.markAsRead(notification.id);
          _showNotificationDetail(context, notification, controller);
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 90),
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
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(top: 2),
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.description,
                      style: AppTextStyles.body.copyWith(
                        color: Colors.grey[700],
                        fontSize: 13,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.formattedTimestamp,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: 8),
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

  void _showNotificationDetail(
    BuildContext context,
    NotificationModel notification,
    NotificationsController controller,
  ) {
    final isMentorshipRequest = notification.actionType == 'mentorship_request' &&
        notification.actionId != null;
    final isMentorshipActive = notification.actionType == 'mentorship_accepted' &&
        notification.actionId != null;

    final meta = notification.metadata;
    final studentBio = meta?['student_bio'] as String? ?? '';
    final hasStudentBio = isMentorshipRequest && studentBio.isNotEmpty;

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
                // Header row
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
                const SizedBox(height: 8),
                Text(
                  notification.formattedTimestamp,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),

                // ── Student bio (mentorship requests only) ───────────────
                if (hasStudentBio) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.blue.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_outline,
                                color: AppColors.blue, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'About the Student',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          studentBio,
                          style: AppTextStyles.body.copyWith(
                            color: Colors.grey[700],
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                // Action buttons
                if (isMentorshipRequest) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            if (checkSubscriptionGate()) return;
                            Get.back();
                            controller.rejectMentorshipRequest(
                              notification.id,
                              notification.actionId!,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.red),
                            minimumSize: const Size(0, 46),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('Decline',
                              style: AppTextStyles.body
                                  .copyWith(color: AppColors.red)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (checkSubscriptionGate()) return;
                            Get.back();
                            controller.acceptMentorshipRequest(
                              notification.id,
                              notification.actionId!,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue,
                            foregroundColor: AppColors.white,
                            minimumSize: const Size(0, 46),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('Accept',
                              style: AppTextStyles.body
                                  .copyWith(color: AppColors.white)),
                        ),
                      ),
                    ],
                  ),
                ] else if (isMentorshipActive) ...[
                  OutlinedButton.icon(
                    icon: const Icon(Icons.person_remove_outlined,
                        color: AppColors.red, size: 20),
                    label: Text('End Mentorship',
                        style:
                            AppTextStyles.body.copyWith(color: AppColors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.red),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Get.back();
                      controller.endMentorshipFromAlumni(
                        notification.id,
                        notification.actionId!,
                      );
                    },
                  ),
                ] else ...[
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
