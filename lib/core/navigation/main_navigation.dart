// lib/core/navigation/main_navigation.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/controllers/navigation_controller.dart';
import 'package:kc_connect/core/config/app_constants.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/bottom_nav_bar.dart';
import 'package:kc_connect/core/routes/app_routes.dart';
import 'package:kc_connect/features/auth/controllers/auth_controller.dart';
import 'package:kc_connect/features/home/presentation/screens/home_page.dart';
import 'package:kc_connect/features/resources/presentation/screens/resources_page.dart';
import 'package:kc_connect/features/chat/presentation/screens/learn_page.dart';
import 'package:kc_connect/features/events/presentation/screens/events_page.dart';
import 'package:kc_connect/features/kstore/presentation/screens/kstore_page.dart';
import 'package:kc_connect/features/alumni/presentation/widgets/alumni_profile_setup_sheet.dart';
import 'package:kc_connect/features/notifications/controllers/notifications_controller.dart';
import 'package:kc_connect/features/payment/presentation/widgets/subscription_payment_modal.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();

  // Static helper for secondary page app bars (used throughout the app)
  static PreferredSizeWidget buildSecondaryAppBar(
    BuildContext context, {
    required String title,
    VoidCallback? onBackPressed,
  }) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 2,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.blue),
        onPressed: onBackPressed ?? () => Get.back(),
      ),
      title: Text(
        title,
        style: AppTextStyles.subHeading.copyWith(
          color: AppColors.blue,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
    );
  }
}

class _MainNavigationState extends State<MainNavigation> {
  late final NavigationController navController;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    navController = Get.put(NavigationController());
    Get.put(NotificationsController());
    _pages = [
      const HomePage(),
      const ResourcesPage(),
      const LearnPage(),
      EventsPage(),
      KstorePage(),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) => _setupUserChecks());
  }

  /// Waits for the user profile to be loaded (the DB trigger may commit a few
  /// hundred ms after auth), then runs the subscription gate and alumni prompt.
  void _setupUserChecks() {
    final auth = Get.find<AuthController>();
    if (auth.currentUser != null) {
      _checkSubscription();
      _scheduleAlumniProfileCheck();
    } else {
      // Profile not yet available — listen reactively and fire once it arrives.
      late Worker worker;
      worker = ever(auth.currentUserRx, (user) {
        if (user != null && mounted) {
          _checkSubscription();
          _scheduleAlumniProfileCheck();
          worker.dispose();
        }
      });
    }
  }

  void _scheduleAlumniProfileCheck() {
    Future.delayed(const Duration(seconds: 30), () {
      if (!mounted) return;
      final user = Get.find<AuthController>().currentUser;
      if (user == null) return;
      if ((user['role'] as String? ?? '') != 'alumni') return;

      final bio = user['bio'] as String? ?? '';
      final vision = user['vision'] as String? ?? '';
      if (bio.isNotEmpty && vision.isNotEmpty) return; // already complete

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => const AlumniProfileSetupSheet(),
      );
    });
  }

  void _checkSubscription() {
    final user = Get.find<AuthController>().currentUser;
    if (user == null) return;

    final role = user['role'] as String? ?? '';
    if (role == 'admin' || role == 'staff') return; // staff/admin are exempt

    final status = user['subscription_status'] as String? ?? 'free';
    final endDateStr = user['subscription_end_date'] as String?;

    bool needsSubscription = status != 'premium';
    if (!needsSubscription && endDateStr != null) {
      final endDate = DateTime.tryParse(endDateStr);
      if (endDate != null && DateTime.now().isAfter(endDate)) {
        needsSubscription = true;
      }
    }

    if (needsSubscription) {
      Get.dialog(
        const SubscriptionPaymentModal(),
        barrierDismissible: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isLargeScreen = constraints.maxWidth >= 600;

        if (isLargeScreen) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
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
                onTap: navController.changePage,
              ),
            ),
          );
        } else {
          return Scaffold(
            resizeToAvoidBottomInset: false,
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
                onTap: navController.changePage,
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
        const titles = ['HOME', 'RESOURCES', 'LEARN', 'EVENTS', 'K-STORE'];
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
        Obx(() {
          final unread = Get.find<NotificationsController>().unreadCount;
          return Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.blue,
                ),
                onPressed: () => Get.toNamed(AppRoutes.news),
              ),
              if (unread > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      unread > 99 ? '99+' : unread.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        }),
        if (showMenuButton)
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.blue),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
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
                    Obx(() {
                      final user = Get.find<AuthController>().currentUser;
                      return Text(
                        user?['full_name'] ?? 'KC Connect',
                        style: AppTextStyles.subHeading.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }),
                    const SizedBox(height: 4),
                    Obx(() {
                      final user = Get.find<AuthController>().currentUser;
                      final role = user?['role'] ?? '';
                      return Text(
                        role.isNotEmpty
                            ? role[0].toUpperCase() + role.substring(1)
                            : 'Welcome back!',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.white.withValues(alpha: 0.8),
                        ),
                      );
                    }),
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
                    Obx(() {
                      final role = Get.find<AuthController>().currentUser?['role'] as String? ?? '';
                      if (role != 'student') return const SizedBox.shrink();
                      return _buildDrawerItem(
                        context,
                        icon: Icons.diversity_3,
                        title: 'Alumni',
                        onTap: () {
                          Navigator.pop(context);
                          Get.toNamed(AppRoutes.alumni);
                        },
                      );
                    }),
                    _buildDrawerItem(
                      context,
                      icon: Icons.settings,
                      title: 'Settings',
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed(AppRoutes.settings);
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
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.logout,
                      title: 'Logout',
                      textColor: AppColors.red,
                      onTap: () {
                        Navigator.pop(context);
                        _showLogoutDialog(context);
                      },
                    ),
                    Obx(() {
                      final role = Get.find<AuthController>().currentUser?['role'] as String? ?? '';
                      if (role != 'admin') return const SizedBox.shrink();
                      return _buildDrawerItem(
                        context,
                        icon: Icons.admin_panel_settings,
                        title: 'Admin Panel',
                        onTap: () {
                          Navigator.pop(context);
                          Get.offAllNamed(AppRoutes.admin);
                        },
                      );
                    }),
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
      hoverColor: AppColors.white.withValues(alpha: 0.1),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  void _showLogoutDialog(BuildContext context) {
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
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
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
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.find<AuthController>().signOut();
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
