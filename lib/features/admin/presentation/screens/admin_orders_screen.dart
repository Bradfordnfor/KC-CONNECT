import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/empty_state.dart';
import 'package:kc_connect/core/widgets/loading_indicator.dart';
import 'package:kc_connect/features/kstore/controllers/store_controller.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StoreController());

    return Material(
      color: AppColors.backgroundColor,
      child: Obx(() {
        if (controller.isLoading) {
          return const Center(child: LoadingIndicator());
        }

        final products = controller.products;

        if (products.isEmpty) {
          return const EmptyState(
            icon: Icons.store_outlined,
            title: 'No Products',
            message: 'No products have been added to the store yet.',
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshProducts,
          color: AppColors.blue,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Store Products',
                style: AppTextStyles.subHeading.copyWith(
                  color: AppColors.blue,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${products.length} product${products.length == 1 ? '' : 's'}',
                style: AppTextStyles.caption.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ...products.map((product) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: product.imageUrl.startsWith('http')
                            ? Image.network(
                                product.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 60,
                                  height: 60,
                                  color: AppColors.backgroundColor,
                                  child: const Icon(Icons.image_not_supported,
                                      color: AppColors.blue, size: 24),
                                ),
                              )
                            : Container(
                                width: 60,
                                height: 60,
                                color: AppColors.backgroundColor,
                                child: const Icon(Icons.shopping_bag,
                                    color: AppColors.blue, size: 24),
                              ),
                      ),
                      const SizedBox(width: 14),

                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.category,
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  product.formattedPrice,
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const Spacer(),
                                _buildStockBadge(product.stock),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStockBadge(int stock) {
    final Color color;
    final String label;
    if (stock == 0) {
      color = AppColors.red;
      label = 'Out of stock';
    } else if (stock <= 5) {
      color = AppColors.warning;
      label = '$stock left';
    } else {
      color = AppColors.success;
      label = '$stock in stock';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
