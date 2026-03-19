// lib/views/admin/pages/admin_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/loading_indicator.dart';
import 'package:kc_connect/features/admin/controllers/admin_dashboard_controller.dart';
import 'package:kc_connect/features/admin/presentation/widgets/metric_card.dart';
import 'package:kc_connect/features/home/controllers/home_controller.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminDashboardController());

    return SingleChildScrollView(
      child: Material(
        color: AppColors.backgroundColor,
        child: Obx(() {
          if (controller.isLoading) {
            return const Center(child: LoadingIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => controller.refreshDashboard(),
            color: AppColors.blue,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome message
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      top: 16.0,
                      right: 16.0,
                    ),
                    child: Text(
                      'Overview',
                      style: AppTextStyles.subHeading.copyWith(
                        color: AppColors.blue,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildWelcomeBanner(HomeController()),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      shrinkWrap: true,
                      childAspectRatio: 1.5,
                      children: [
                        // Total Users
                        MetricCard(
                          title: 'Total Users',
                          value: '${controller.totalUsers}',
                          subtitle:
                              'Students: ${controller.studentCount} | Alumni: ${controller.alumniCount}\nStaff: ${controller.staffCount} | Admin: ${controller.adminCount}',
                          icon: Icons.people,
                          color: AppColors.blue,
                        ),

                        // Total Resources
                        MetricCard(
                          title: 'Total Resources',
                          value: '${controller.totalResources}',
                          icon: Icons.book,
                          color: AppColors.success,
                        ),

                        // Total Events
                        MetricCard(
                          title: 'Total Events',
                          value: '${controller.totalEvents}',
                          icon: Icons.event,
                          color: AppColors.info,
                        ),

                        // Total Products
                        MetricCard(
                          title: 'Total Products',
                          value: '${controller.totalProducts}',
                          icon: Icons.shopping_bag,
                          color: AppColors.warning,
                        ),

                        // Pending OTPs
                        MetricCard(
                          title: 'Pending OTPs',
                          value: '${controller.pendingOTPs}',
                          subtitle: controller.pendingOTPs > 0
                              ? 'Requires attention'
                              : 'All clear',
                          icon: Icons.pending_actions,
                          color: controller.pendingOTPs > 0
                              ? AppColors.error
                              : AppColors.success,
                        ),

                        // Monthly Revenue
                        MetricCard(
                          title: 'Revenue (Month)',
                          value:
                              '${(controller.monthlyRevenue / 1000).toStringAsFixed(0)}K XAF',
                          icon: Icons.attach_money,
                          color: AppColors.success,
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

Widget _buildWelcomeBanner(HomeController controller) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: AppColors.gradientColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: AppColors.red.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.welcomeMessage,
                    style: AppTextStyles.subHeading.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.getMotivationalMessage(),
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.school, color: AppColors.white, size: 28),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Activity Summary
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.trending_up, color: AppColors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.getActivitySummary(),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
