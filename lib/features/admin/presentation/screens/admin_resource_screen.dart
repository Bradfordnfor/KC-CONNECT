// lib/views/admin/pages/admin_resources_page.dart
import 'package:flutter/material.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/common/dialog.dart';

class AdminResourcesPage extends StatelessWidget {
  const AdminResourcesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Most Downloaded Card
            _buildMostDownloadedCard(),
            const SizedBox(height: 24),

            Text(
              'All Resources',
              style: AppTextStyles.subHeading.copyWith(
                color: AppColors.blue,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),

            _buildResourcesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMostDownloadedCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.blue, AppColors.blue.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: AppColors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Most Downloaded',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Advanced Mathematics O/L',
            style: AppTextStyles.subHeading.copyWith(
              color: AppColors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '1,234 Downloads • Mathematics • O/L',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesList() {
    final resources = [
      {'title': 'Physics A/L Notes', 'subject': 'Physics', 'downloads': 856},
      {'title': 'Chemistry Guide', 'subject': 'Chemistry', 'downloads': 654},
      {'title': 'English Grammar', 'subject': 'English', 'downloads': 542},
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: resources.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final resource = resources[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource['title'] as String,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${resource['downloads']} downloads',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () async {
                  final confirmed = await AppDialog.confirmDelete(
                    context: context,
                    title: 'Delete Resource',
                    message:
                        'Are you sure you want to delete this resource? This action cannot be undone.',
                    onConfirm: () async {
                      // TODO: Implement actual delete with Supabase
                      // await Supabase.instance.client.from('resources').delete().eq('id', resource['id']);
                      Navigator.pop(context);
                      // Optionally refresh resources list
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
