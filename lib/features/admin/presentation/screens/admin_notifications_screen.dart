import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/models/notification_model.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/features/notifications/controllers/notifications_controller.dart';

class AdminNotificationsPage extends StatelessWidget {
  const AdminNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationsController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.blue),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Notifications',
          style: AppTextStyles.subHeading.copyWith(
            color: AppColors.blue,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() => Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.done_all, color: AppColors.blue),
                    tooltip: 'Mark all read',
                    onPressed: controller.unreadCount > 0
                        ? controller.markAllAsRead
                        : null,
                  ),
                  if (controller.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${controller.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              )),
        ],
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.blue));
        }
        if (controller.allNotifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off_outlined,
                    size: 60,
                    color: AppColors.blue.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text('No notifications',
                    style: AppTextStyles.subHeading
                        .copyWith(color: AppColors.blue)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          color: AppColors.blue,
          onRefresh: controller.refreshNotifications,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.allNotifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final n = controller.allNotifications[index];
              return _buildNotificationCard(context, n, controller);
            },
          ),
        );
      }),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel n,
    NotificationsController controller,
  ) {
    final isUnread = !n.isRead;

    return GestureDetector(
      onTap: () {
        controller.markAsRead(n.id);
        // OTP approval notifications are handled inline — no detail dialog needed
        if (n.actionType != 'otp_approval') {
          _showDetailDialog(context, n, controller);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread
              ? AppColors.blue.withValues(alpha: 0.05)
              : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnread
                ? AppColors.blue.withValues(alpha: 0.2)
                : AppColors.backgroundColor,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_iconForType(n.type),
                  color: AppColors.blue, size: 22),
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
                            color: AppColors.red,
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
                    maxLines: n.actionType == 'otp_approval' ? 3 : 2,
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
                  // Inline approve/reject for OTP signup requests
                  if (n.actionType == 'otp_approval' &&
                      n.actionId != null)
                    _buildOTPActions(context, n, controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOTPActions(
    BuildContext context,
    NotificationModel n,
    NotificationsController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () =>
                  _showRejectDialog(context, n, controller),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.red),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Reject',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () =>
                  controller.approveSignup(n.id, n.actionId!),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Approve',
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

  void _showRejectDialog(
    BuildContext context,
    NotificationModel n,
    NotificationsController controller,
  ) {
    final reasonController = TextEditingController();
    final meta = n.metadata;
    final applicantName = meta?['applicant_name'] as String? ?? 'the applicant';

    // Use a bottom sheet so the TextField + keyboard never overflow
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.viewInsetsOf(ctx).bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cancel_outlined, color: AppColors.red, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Reject $applicantName',
                    style: AppTextStyles.subHeading
                        .copyWith(color: AppColors.blue, fontSize: 17),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Provide a reason — it will be emailed to the applicant.',
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 4,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. We cannot verify your employment at this time.',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.blue),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Cancel',
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.textSecondary)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final reason = reasonController.text.trim();
                      if (reason.isEmpty) return;
                      Navigator.pop(ctx);
                      controller.rejectSignupFromNotification(
                          n.id, n.actionId!, reason);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size(0, 46),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Send Rejection'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailDialog(
    BuildContext context,
    NotificationModel n,
    NotificationsController controller,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          n.title,
          style: AppTextStyles.subHeading.copyWith(color: AppColors.blue),
        ),
        content: Text(n.description, style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
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
      case 'otp_approval':
        return Icons.verified_user_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }
}
