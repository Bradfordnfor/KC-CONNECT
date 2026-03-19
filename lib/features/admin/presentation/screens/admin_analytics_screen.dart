import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';

class AdminAnalyticsPage extends StatelessWidget {
  const AdminAnalyticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Growth Metrics',
              style: AppTextStyles.subHeading.copyWith(
                color: AppColors.blue,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              'User Growth',
              '+150 this month',
              Icons.trending_up,
              AppColors.success,
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              'Resource Uploads',
              '45 new resources',
              Icons.upload,
              AppColors.info,
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              'Event Registrations',
              '234 registrations',
              Icons.event,
              AppColors.warning,
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              'Revenue Trend',
              '+25% growth',
              Icons.attach_money,
              AppColors.success,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Charts will be implemented with fl_chart package',
                      style: AppTextStyles.body.copyWith(color: AppColors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.blue,
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
