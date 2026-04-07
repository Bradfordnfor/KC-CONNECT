import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/loading_indicator.dart';
import 'package:kc_connect/features/admin/controllers/admin_analytics_controller.dart';

class AdminAnalyticsPage extends StatelessWidget {
  const AdminAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminAnalyticsController());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: AppTextStyles.subHeading.copyWith(color: AppColors.blue),
        ),
        backgroundColor: AppColors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.blue),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.blue),
            onPressed: controller.refresh,
          ),
        ],
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: LoadingIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.refresh,
          color: AppColors.blue,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Platform Overview'),
                const SizedBox(height: 12),
                _buildOverviewGrid(controller),
                const SizedBox(height: 24),
                _buildSectionTitle('User Distribution'),
                const SizedBox(height: 12),
                _buildUserDistribution(controller),
                const SizedBox(height: 24),
                _buildSectionTitle('This Week'),
                const SizedBox(height: 12),
                _buildWeeklyStats(controller),
                const SizedBox(height: 24),
                _buildSectionTitle('Recent Orders'),
                const SizedBox(height: 12),
                _buildRecentOrders(controller),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: AppTextStyles.body.copyWith(
        color: Colors.grey[600],
        fontWeight: FontWeight.bold,
        fontSize: 12,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildOverviewGrid(AdminAnalyticsController c) {
    // mainAxisExtent fixes card height regardless of screen width,
    // eliminating overflow on narrow devices.
    return GridView.custom(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        mainAxisExtent: 118,
      ),
      childrenDelegate: SliverChildListDelegate([
        _buildStatCard(
          label: 'Total Users',
          value: c.totalUsers.toString(),
          icon: Icons.people,
          color: AppColors.blue,
        ),
        _buildStatCard(
          label: 'Resources',
          value: c.totalResources.toString(),
          icon: Icons.library_books,
          color: AppColors.info,
        ),
        _buildStatCard(
          label: 'Events',
          value: c.totalEvents.toString(),
          icon: Icons.event,
          color: AppColors.warning,
        ),
        _buildStatCard(
          label: 'Total Revenue',
          value: 'XAF ${_formatNumber(c.totalRevenue)}',
          icon: Icons.payments_outlined,
          color: AppColors.success,
        ),
      ]),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.subHeading.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.blue,
              fontSize: 18,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.grey[500],
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildUserDistribution(AdminAnalyticsController c) {
    final roles = [
      ('Students', 'student', AppColors.blue),
      ('Alumni', 'alumni', AppColors.deepRed),
      ('Staff', 'staff', AppColors.warning),
      ('Admins', 'admin', AppColors.success),
    ];
    final total = c.totalUsers == 0 ? 1 : c.totalUsers;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: roles.map((entry) {
          final label = entry.$1;
          final key = entry.$2;
          final color = entry.$3;
          final count = c.usersByRole[key] ?? 0;
          final pct = count / total;

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '$count  (${(pct * 100).toStringAsFixed(1)}%)',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 8,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWeeklyStats(AdminAnalyticsController c) {
    return Row(
      children: [
        Expanded(
          child: _buildHighlightCard(
            icon: Icons.person_add_outlined,
            label: 'New Signups',
            value: c.recentSignups.toString(),
            sublabel: 'last 7 days',
            color: AppColors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildHighlightCard(
            icon: Icons.download_outlined,
            label: 'Downloads',
            value: c.totalDownloads.toString(),
            sublabel: 'total',
            color: AppColors.info,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildHighlightCard(
            icon: Icons.workspace_premium_outlined,
            label: 'Premium',
            value: c.activeSubscriptions.toString(),
            sublabel: 'active',
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightCard({
    required IconData icon,
    required String label,
    required String value,
    required String sublabel,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.subHeading.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppColors.blue,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            sublabel,
            style: AppTextStyles.caption.copyWith(
              color: Colors.grey[400],
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders(AdminAnalyticsController c) {
    if (c.recentOrders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No orders yet',
            style: AppTextStyles.body.copyWith(color: Colors.grey[500]),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: c.recentOrders.asMap().entries.map((entry) {
          final i = entry.key;
          final order = entry.value;
          final isPaid = order['payment_status'] == 'paid';
          final total = (order['total'] as num?)?.toDouble() ?? 0.0;
          final orderNum = order['order_number'] as String? ?? '—';
          final date = order['created_at'] != null
              ? DateTime.tryParse(order['created_at'] as String)
              : null;

          return Column(
            children: [
              if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                dense: true,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (isPaid ? AppColors.success : AppColors.warning)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isPaid
                        ? Icons.check_circle_outline
                        : Icons.pending_outlined,
                    color: isPaid ? AppColors.success : AppColors.warning,
                    size: 18,
                  ),
                ),
                title: Text(
                  '#$orderNum',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                subtitle: Text(
                  date != null ? '${date.day}/${date.month}/${date.year}' : '—',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'XAF ${_formatNumber(total)}',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.blue,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: (isPaid ? AppColors.success : AppColors.warning)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isPaid ? 'PAID' : 'PENDING',
                        style: AppTextStyles.caption.copyWith(
                          color: isPaid ? AppColors.success : AppColors.warning,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}
