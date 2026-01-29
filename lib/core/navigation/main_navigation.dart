// lib/core/navigation/main_navigation.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/controllers/navigation_controller.dart';
import 'package:kc_connect/core/config/app_constants.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/bottom_nav_bar.dart';
import 'package:kc_connect/features/home/presentation/screens/home_page.dart';
import 'package:kc_connect/features/resources/presentation/screens/resources_page.dart';
import 'package:kc_connect/features/chat/presentation/screens/learn_page.dart';
import 'package:kc_connect/features/events/presentation/screens/events_page.dart';
import 'package:kc_connect/features/alumni/presentation/screens/alumni_page.dart';
import 'package:kc_connect/features/notifications/presentation/screens/news_page.dart';
import 'package:kc_connect/features/profile/presentation/screens/profile_page.dart';

class MainNavigation extends StatelessWidget {
  MainNavigation({super.key});

  final NavigationController navController = Get.put(NavigationController());

  final List<Widget> _pages = [
    const HomePage(),
    const ResourcesPage(),
    const LearnPage(),
    const EventsPage(),
    const HomePage(), // Replace with KStorePage when created
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      endDrawer: _buildDrawer(context),
      body: Obx(
        () => IndexedStack(index: navController.currentIndex, children: _pages),
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
            Get.to(() => _buildPageWithAppBar(const NewsPage(), 'NEWS'));
          },
        ),
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
                        Get.to(
                          () => _buildPageWithAppBar(
                            const ProfilePage(),
                            'PROFILE',
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.diversity_3,
                      title: 'Alumni',
                      onTap: () {
                        Navigator.pop(context);
                        Get.to(
                          () => _buildPageWithAppBar(
                            const AlumniPage(),
                            'ALUMNI',
                          ),
                        );
                      },
                    ),
                    // REMOVED NOTIFICATIONS FROM DRAWER
                    _buildDrawerItem(
                      context,
                      icon: Icons.settings,
                      title: 'Settings',
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to settings
                      },
                    ),
                    const Divider(color: AppColors.white, thickness: 0.5),
                    _buildDrawerItem(
                      context,
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to help
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.logout,
                      title: 'Logout',
                      textColor: AppColors.red,
                      onTap: () {
                        Navigator.pop(context);
                        // Handle logout
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

  // Wrapper to add AppBar to drawer pages (no bottom nav, no back button)
  Widget _buildPageWithAppBar(Widget page, String title) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.blue),
          onPressed: () => Get.back(),
        ),

        title: Text(
          title,
          style: AppTextStyles.subHeading.copyWith(
            color: AppColors.deepRed,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.blue,
            ),
            onPressed: () {
              // If already on NEWS page, do nothing
              if (title != 'NEWS') {
                Get.to(() => _buildPageWithAppBar(const NewsPage(), 'NEWS'));
              }
            },
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.blue),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: _buildDrawer(Get.context!),
      body: page,
    );
  }
}
