import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/common/dialog.dart';
import 'package:kc_connect/core/widgets/empty_state.dart';
import 'package:kc_connect/core/widgets/loading_indicator.dart';
import 'package:kc_connect/features/admin/controllers/admin_resources_controller.dart';

class AdminResourcesPage extends StatelessWidget {
  const AdminResourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminResourcesController());

    return Material(
      color: AppColors.backgroundColor,
      child: Obx(() {
        if (controller.isLoading) {
          return const Center(child: LoadingIndicator());
        }

        if (controller.resources.isEmpty) {
          return const EmptyState(
            icon: Icons.folder_open,
            title: 'No Resources',
            message: 'No resources have been uploaded yet',
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshResources(),
          color: AppColors.blue,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopCard(controller),
                const SizedBox(height: 24),
                Text(
                  'All Resources',
                  style: AppTextStyles.subHeading.copyWith(
                    color: AppColors.blue,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                _buildList(context, controller),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTopCard(AdminResourcesController controller) {
    final top = controller.topResource;
    if (top == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.blue, AppColors.blue.withValues(alpha: 0.8)],
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
            top['title'] as String? ?? '—',
            style: AppTextStyles.subHeading.copyWith(
              color: AppColors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${top['download_count'] ?? 0} Downloads · '
            '${top['subject'] ?? ''} · ${top['category'] ?? ''}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, AdminResourcesController controller) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.resources.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final resource = controller.resources[index];
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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource['title'] as String? ?? '—',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${resource['download_count'] ?? 0} downloads'
                      '${resource['subject'] != null ? ' · ${resource['subject']}' : ''}',
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
                  await AppDialog.confirmDelete(
                    context: context,
                    title: 'Delete Resource',
                    message:
                        'Are you sure you want to delete "${resource['title']}"? '
                        'This cannot be undone.',
                    onConfirm: () async {
                      await controller.deleteResource(
                        resource['id'] as String,
                      );
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
