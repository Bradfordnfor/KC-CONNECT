// lib/features/home/presentation/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/controllers/navigation_controller.dart';
import 'package:kc_connect/core/widgets/carousel_widget.dart';
import 'package:kc_connect/core/widgets/loading_indicator.dart';
import 'package:kc_connect/core/widgets/error_widget.dart';
import 'package:kc_connect/features/auth/controllers/auth_controller.dart';
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
                _buildOfTheMonthSection(controller),
                const SizedBox(height: 24),
                _buildLeaderboardSection(controller),
                const SizedBox(height: 24),
                _buildRecentResourcesSection(controller, navController),
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
            color: AppColors.red.withValues(alpha: 0.3),
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
                        color: AppColors.white.withValues(alpha: 0.9),
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
                  color: AppColors.white.withValues(alpha: 0.2),
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
          // Points + Activity row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${controller.getStat('userPoints')} pts',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Stats Cards
  Widget _buildStatsCards(
    HomeController controller,
    NavigationController navController,
  ) {
    final role = Get.find<AuthController>().currentUser?['role'] as String? ?? 'student';
    final isStudent = role == 'student';

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
              onTap: () => navController.changePage(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.book,
              label: 'Resources',
              value: controller.getStat('resources').toString(),
              color: AppColors.deepRed,
              onTap: () => navController.changePage(1),
            ),
          ),
          const SizedBox(width: 12),
          // Students see Alumni count → alumni page
          // Staff / Alumni see active pinned messages → chat page
          Expanded(
            child: isStudent
                ? _buildStatCard(
                    icon: Icons.people,
                    label: 'Alumni',
                    value: controller.getStat('alumni').toString(),
                    color: AppColors.blue,
                    onTap: () => Get.toNamed('/alumni'),
                  )
                : _buildStatCard(
                    icon: Icons.push_pin,
                    label: 'Pinned',
                    value: controller.getStat('pinnedMessages').toString(),
                    color: Colors.amber[700]!,
                    onTap: () => navController.changePage(2), // Learn/Chat
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
              color: Colors.black.withValues(alpha: 0.05),
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

  Widget _buildQuickActionsGrid(NavigationController navController) {
    final role = Get.find<AuthController>().currentUser?['role'] as String? ?? 'student';
    final isStudent = role == 'student';

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
                  onTap: () => navController.changePage(3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.menu_book,
                  label: 'Resources',
                  color: AppColors.deepRed,
                  onTap: () => navController.changePage(1),
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
                child: isStudent
                    ? _buildQuickActionCard(
                        icon: Icons.people_outline,
                        label: 'Find Mentors',
                        color: AppColors.blue,
                        onTap: () => Get.toNamed('/alumni'),
                      )
                    : _buildQuickActionCard(
                        icon: Icons.forum_outlined,
                        label: 'Help Students',
                        color: AppColors.blue,
                        onTap: () => navController.changePage(2), // Learn/Chat page
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.shopping_bag_outlined,
                  label: 'K-Store',
                  color: AppColors.deepRed,
                  onTap: () => navController.changePage(4),
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
              color: Colors.black.withValues(alpha: 0.05),
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

  // ─── Of-the-Month ──────────────────────────────────────────────────────────

  Widget _buildOfTheMonthSection(HomeController controller) {
    return Obx(() {
      final top = controller.ofTheMonth;
      if (top == null) return const SizedBox.shrink();

      final role = Get.find<AuthController>().currentUser?['role'] as String? ?? '';
      final label = role == 'alumni'
          ? 'Alumni of the Month'
          : role == 'staff'
              ? 'Staff of the Month'
              : 'Student of the Month';

      final name      = top['full_name']           as String? ?? 'Unknown';
      final pts       = top['points_this_month']   as int?    ?? 0;
      final avatarUrl = top['profile_image_url'] as String?;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.gradientColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.red.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.white.withValues(alpha: 0.3),
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: AppTextStyles.subHeading.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.amber, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: AppTextStyles.subHeading.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$pts pts this month',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // ─── Leaderboard ───────────────────────────────────────────────────────────

  Widget _buildLeaderboardSection(HomeController controller) {
    return Obx(() {
      final board = controller.leaderboard;
      if (board.isEmpty) return const SizedBox.shrink();

      final role = Get.find<AuthController>().currentUser?['role'] as String? ?? '';
      final title = role == 'alumni'
          ? 'Alumni Leaderboard'
          : role == 'staff'
              ? 'Staff Leaderboard'
              : 'Student Leaderboard';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.leaderboard, color: AppColors.blue, size: 22),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyles.subHeading.copyWith(
                    color: AppColors.blue,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: board.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final entry     = board[index];
                final name      = entry['full_name']           as String? ?? 'Unknown';
                final pts       = entry['points']              as int?    ?? 0;
                final avatarUrl = entry['profile_image_url'] as String?;
                final rank      = index + 1;

                final rankColor = rank == 1
                    ? Colors.amber
                    : rank == 2
                        ? Colors.grey[400]!
                        : rank == 3
                            ? const Color(0xFFCD7F32)
                            : AppColors.blue.withValues(alpha: 0.5);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Rank badge
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: rankColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$rank',
                            style: AppTextStyles.caption.copyWith(
                              color: rankColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Avatar
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.blue.withValues(alpha: 0.12),
                        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                        child: avatarUrl == null
                            ? Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      // Name
                      Expanded(
                        child: Text(
                          name,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Points
                      Text(
                        '$pts pts',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
    });
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
                      color: Colors.black.withValues(alpha: 0.05),
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
            color: Colors.black.withValues(alpha: 0.05),
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
            color: color.withValues(alpha: 0.1),
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
