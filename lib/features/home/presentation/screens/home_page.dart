// lib/features/home/presentation/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/controllers/navigation_controller.dart';
import 'package:kc_connect/core/widgets/carousel_widget.dart';
import 'package:kc_connect/core/widgets/loading_indicator.dart';
import 'package:kc_connect/core/widgets/error_widget.dart';
import 'package:kc_connect/features/home/controllers/home_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    final NavigationController navController = Get.find<NavigationController>();

    return Container(
      color: AppColors.backgroundColor,
      child: RefreshIndicator(
        onRefresh: () => controller.refreshDashboard(),
        color: AppColors.blue,
        child: Obx(() {
          if (controller.isLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (controller.errorMessage.isNotEmpty) {
            return ErrorDisplay(
              message: controller.errorMessage,
              onRetry: () => controller.refreshDashboard(),
            );
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildWelcomeBanner(controller),
                const SizedBox(height: 20),
                _buildStatsCards(controller, navController),
                const SizedBox(height: 24),
                _buildFeaturedEventsSection(controller, navController),
                const SizedBox(height: 24),
                _buildQuickActionsGrid(navController),
                const SizedBox(height: 24),
                _buildRecentResourcesSection(controller, navController),
                const SizedBox(height: 24),
                _buildFeaturedAlumniSection(controller, navController),
                const SizedBox(height: 24),
                _buildActivitySection(controller),
              ],
            ),
          );
        }),
      ),
    );
  }

  // Welcome Banner
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
                child: const Icon(
                  Icons.school,
                  color: AppColors.white,
                  size: 28,
                ),
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

  // Stats Cards - FIXED: Uses bottom nav index
  Widget _buildStatsCards(
    HomeController controller,
    NavigationController navController,
  ) {
    return Container(
      height: 125,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.event,
              label: 'Events',
              value: controller.getStat('events').toString(),
              color: AppColors.blue,
              onTap: () => navController.changePage(3), // Index 3 = Events
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.book,
              label: 'Resources',
              value: controller.getStat('resources').toString(),
              color: AppColors.deepRed,
              onTap: () => navController.changePage(1), // Index 1 = Resources
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.people,
              label: 'Alumni',
              value: controller.getStat('alumni').toString(),
              color: AppColors.blue,
              onTap: () {
                // Alumni is not in bottom nav, so use Get.toNamed
                Get.toNamed('/alumni');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.subHeading.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Featured Events Section - FIXED: Uses bottom nav index
  Widget _buildFeaturedEventsSection(
    HomeController controller,
    NavigationController navController,
  ) {
    if (controller.featuredEvents.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Events',
                style: AppTextStyles.subHeading.copyWith(
                  color: AppColors.blue,
                  fontSize: 18,
                ),
              ),
              TextButton(
                onPressed: () =>
                    navController.changePage(3), // Index 3 = Events
                child: Text(
                  'See All',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        CarouselWidget(
          height: 150,
          autoPlay: true,
          autoPlayDuration: const Duration(seconds: 5),
          items: controller.featuredEvents.map((event) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.gradientColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    event.daysToGo.toString(),
                    style: AppTextStyles.heading.copyWith(
                      color: AppColors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'DAYS TO GO',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.white,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.title,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Quick Actions Grid - FIXED: Uses bottom nav index
  Widget _buildQuickActionsGrid(NavigationController navController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Quick Actions',
            style: AppTextStyles.subHeading.copyWith(
              color: AppColors.blue,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.event_available,
                  label: 'Browse Events',
                  color: AppColors.blue,
                  onTap: () => navController.changePage(3), // Index 3 = Events
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.menu_book,
                  label: 'Resources',
                  color: AppColors.deepRed,
                  onTap: () =>
                      navController.changePage(1), // Index 1 = Resources
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.people_outline,
                  label: 'Find Mentors',
                  color: AppColors.blue,
                  onTap: () => Get.toNamed('/alumni'), // Not in bottom nav
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.shopping_bag_outlined,
                  label: 'K-Store',
                  color: AppColors.deepRed,
                  onTap: () => navController.changePage(4), // Index 4 = Store
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Recent Resources Section - FIXED: Uses bottom nav index
  Widget _buildRecentResourcesSection(
    HomeController controller,
    NavigationController navController,
  ) {
    if (controller.recentResources.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Resources',
                style: AppTextStyles.subHeading.copyWith(
                  color: AppColors.blue,
                  fontSize: 18,
                ),
              ),
              TextButton(
                onPressed: () =>
                    navController.changePage(1), // Index 1 = Resources
                child: Text(
                  'See All',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.recentResources.take(5).length,
            itemBuilder: (context, index) {
              final resource = controller.recentResources[index];
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.book, color: AppColors.blue, size: 20),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            resource.category,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.blue,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      resource.title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      resource.displayPages,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Featured Alumni Section
  Widget _buildFeaturedAlumniSection(
    HomeController controller,
    NavigationController navController,
  ) {
    if (controller.featuredAlumni.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Connect with Alumni',
                style: AppTextStyles.subHeading.copyWith(
                  color: AppColors.blue,
                  fontSize: 18,
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed('/alumni'), // Not in bottom nav
                child: Text(
                  'See All',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 135,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.featuredAlumni.take(3).length,
            itemBuilder: (context, index) {
              final alumni = controller.featuredAlumni[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      alumni.name,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alumni.role,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Activity Section
  Widget _buildActivitySection(HomeController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, color: AppColors.blue, size: 24),
              const SizedBox(width: 8),
              Text(
                'Your Activity',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            icon: Icons.event_available,
            label: 'Registered Events',
            value: controller.getStat('myEvents').toString(),
            color: AppColors.blue,
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            icon: Icons.bookmark,
            label: 'Saved Resources',
            value: controller.getStat('myResources').toString(),
            color: AppColors.deepRed,
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            icon: Icons.notifications_active,
            label: 'Unread Notifications',
            value: controller.getStat('notifications').toString(),
            color: AppColors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: AppTextStyles.body.copyWith(fontSize: 14)),
        ),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
