import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';

class AdminNotificationsPage extends StatelessWidget {
  const AdminNotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          IconButton(
            icon: const Icon(Icons.done_all, color: AppColors.blue),
            onPressed: () {
              // Mark all as read
            },
          ),
        ],
      ),
      backgroundColor: AppColors.backgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationCard(
            icon: Icons.verified_user,
            iconColor: AppColors.blue,
            title: 'New OTP Request',
            message: 'John Doe requested OTP approval for staff role',
            time: '5 minutes ago',
            isUnread: true,
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            icon: Icons.upload_file,
            iconColor: const Color(0xFF10B981),
            title: 'Resource Uploaded',
            message:
                'New resource "Advanced Mathematics" uploaded by Jane Smith',
            time: '1 hour ago',
            isUnread: true,
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            icon: Icons.event_available,
            iconColor: const Color(0xFF7C3AED),
            title: 'Event Created',
            message: 'Alumni Meetup 2024 created by Mike Johnson',
            time: '3 hours ago',
            isUnread: false,
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            icon: Icons.shopping_cart,
            iconColor: const Color(0xFFF59E0B),
            title: 'New Order',
            message: 'Order #12345 placed - KC Uniform (Size M)',
            time: '1 day ago',
            isUnread: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String time,
    required bool isUnread,
  }) {
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
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
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
                        title,
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
                  message,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  time,
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
