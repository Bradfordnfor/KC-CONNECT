// lib/core/navigation/main_navigation.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/controllers/navigation_controller.dart';
import 'package:kc_connect/core/config/app_constants.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/bottom_nav_bar.dart';
import 'package:kc_connect/core/routes/app_routes.dart';
import 'package:kc_connect/features/home/presentation/screens/home_page.dart';
import 'package:kc_connect/features/resources/presentation/screens/resources_page.dart';
import 'package:kc_connect/features/chat/presentation/screens/learn_page.dart';
import 'package:kc_connect/features/events/presentation/screens/events_page.dart';
import 'package:kc_connect/features/kstore/presentation/screens/kstore_page.dart';

class MainNavigation extends StatelessWidget {
  MainNavigation({super.key});

  final NavigationController navController = Get.put(NavigationController());

  final List<Widget> _pages = [
    const HomePage(),
    const ResourcesPage(),
    const LearnPage(),
    EventsPage(),
    KstorePage(),
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
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          AppConstants.appIcon,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.school, color: AppColors.blue);
          },
        ),
      ),
      title: Obx(() {
        final titles = ['HOME', 'RESOURCES', 'LEARN', 'EVENTS', 'K-STORE'];
        return Text(
          titles[navController.currentIndex],
          style: AppTextStyles.subHeading.copyWith(
            color: AppColors.deepRed,
            fontSize: 20,
          ),
        );
      }),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppColors.blue),
          onPressed: () {
            // Navigate to news page using GetX routes
            Get.toNamed(AppRoutes.news);
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
                        Icons.person,
                        size: 35,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'KC Connect',
                      style: AppTextStyles.subHeading.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Welcome back!',
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
                      icon: Icons.home,
                      title: 'Home',
                      onTap: () {
                        Navigator.pop(context);
                        navController.goToHome();
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.person,
                      title: 'Profile',
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed(AppRoutes.profile);
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.diversity_3,
                      title: 'Alumni',
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed(AppRoutes.alumni);
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.settings,
                      title: 'Settings',
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed(AppRoutes.settings);
                        // Get.snackbar(
                        //   'Coming Soon',
                        //   'Settings page will be available soon',
                        //   snackPosition: SnackPosition.BOTTOM,
                        //   backgroundColor: AppColors.blue,
                        //   colorText: AppColors.white,
                        //   margin: const EdgeInsets.all(16),
                        // );
                      },
                    ),
                    const Divider(color: AppColors.white, thickness: 0.5),
                    _buildDrawerItem(
                      context,
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed(AppRoutes.help);
                        // Get.snackbar(
                        //   'Coming Soon',
                        //   'Help & Support page will be available soon',
                        //   snackPosition: SnackPosition.BOTTOM,
                        //   backgroundColor: AppColors.blue,
                        //   colorText: AppColors.white,
                        //   margin: const EdgeInsets.all(16),
                        // );
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.logout,
                      title: 'Logout',
                      textColor: AppColors.red,
                      onTap: () {
                        Navigator.pop(context);
                        // Will be implemented with authentication
                        _showLogoutDialog();
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

  void _showLogoutDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.logout, color: AppColors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Logout',
                style: AppTextStyles.subHeading.copyWith(color: AppColors.blue),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to logout?',
                style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.blue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        // TODO: Implement actual logout logic
                        Get.snackbar(
                          'Logged Out',
                          'You have been logged out successfully',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.blue,
                          colorText: AppColors.white,
                          margin: const EdgeInsets.all(16),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Logout'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
