// lib/views/admin/admin_main_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/controllers/navigation_controller.dart';
import 'package:kc_connect/core/config/app_constants.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/bottom_nav_bar.dart';
import 'package:kc_connect/features/admin/presentation/screens/admin_analytics_screen.dart';
import 'package:kc_connect/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:kc_connect/features/admin/presentation/screens/admin_events_screen.dart';
import 'package:kc_connect/features/admin/presentation/screens/admin_notifications_screen.dart';
import 'package:kc_connect/features/admin/presentation/screens/admin_orders_screen.dart';
import 'package:kc_connect/features/admin/presentation/screens/admin_otp_approvals_screen.dart';
import 'package:kc_connect/features/admin/presentation/screens/admin_resource_screen.dart';
import 'package:kc_connect/features/admin/presentation/screens/admin_setting_screen.dart';
import 'package:kc_connect/features/admin/presentation/screens/admin_users_screen.dart';
import 'package:kc_connect/features/admin/presentation/widgets/broadcast_modal.dart';

class AdminMainPage extends StatelessWidget {
  AdminMainPage({super.key});

  final NavigationController navController = Get.put(NavigationController());

  final List<Widget> _pages = [
    const AdminDashboardPage(),
    const AdminResourcesPage(),
    const AdminUsersPage(),
    const AdminEventsPage(),
    const AdminOrdersPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isLargeScreen = constraints.maxWidth >= 600;

        if (isLargeScreen) {
          // Large screen: drawer always visible
          return Scaffold(
            appBar: _buildAppBar(context, showMenuButton: false),
            body: Row(
              children: [
                SizedBox(width: 280, child: _buildDrawer(context)),
                Expanded(
                  child: Obx(
                    () => IndexedStack(
                      index: navController.currentIndex,
                      children: _pages,
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: Obx(
              () => BottomNavBar(
                currentIndex: navController.currentIndex,
                onTap: (index) {
                  navController.changePage(index);
                },
              ),
            ),
          );
        } else {
          // Small screen: drawer hidden
          return Scaffold(
            appBar: _buildAppBar(context, showMenuButton: true),
            endDrawer: _buildDrawer(context),
            body: Obx(
              () => IndexedStack(
                index: navController.currentIndex,
                children: _pages,
              ),
            ),
            bottomNavigationBar: Obx(
              () => BottomNavBar(
                currentIndex: navController.currentIndex,
                onTap: (index) {
                  navController.changePage(index);
                },
              ),
            ),
          );
        }
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context, {
    required bool showMenuButton,
  }) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 2,
      leading: Image.asset(
        height: 30,
        width: 30,
        AppConstants.appIcon,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.admin_panel_settings, color: AppColors.blue);
        },
      ),
      title: Padding(
        padding: const EdgeInsets.only(right: 6.0),
        child: Text(
          'WELCOME, ADMIN',
          style: AppTextStyles.subHeading.copyWith(
            color: AppColors.deepRed,
            fontSize: 20,
          ),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppColors.blue),
          onPressed: () {
            Get.to(() => const AdminNotificationsPage());
          },
        ),
        if (showMenuButton)
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.blue),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: AppColors.blue,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.gradientColor,
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        size: 35,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Admin Panel',
                      style: AppTextStyles.subHeading.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage KC Connect',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.white, thickness: 0.5),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem(
                      context,
                      icon: Icons.analytics,
                      title: 'Analytics',
                      onTap: () {
                        Navigator.pop(context);
                        Get.to(() => const AdminAnalyticsPage());
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.settings,
                      title: 'Settings',
                      onTap: () {
                        Navigator.pop(context);
                        Get.to(() => const AdminSettingsPage());
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.pending_actions,
                      title: 'OTP Approvals',
                      onTap: () {
                        Navigator.pop(context);
                        Get.to(() => const AdminOTPApprovalsPage());
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.campaign,
                      title: 'News/Announcements',
                      onTap: () {
                        Navigator.pop(context);
                        showBroadcastModal(context);
                      },
                    ),
                    const Divider(color: AppColors.white, thickness: 0.5),
                    _buildDrawerItem(
                      context,
                      icon: Icons.work,
                      title: 'Switch to Staff',
                      textColor: AppColors.white,
                      onTap: () {
                        Navigator.pop(context);
                        Get.back(); // Return to main app
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.white, size: 24),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(
          color: textColor ?? AppColors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      hoverColor: AppColors.white.withOpacity(0.1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
