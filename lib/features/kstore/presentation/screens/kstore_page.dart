// lib/features/store/presentation/screens/store_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/carousel_widget.dart';
import 'package:kc_connect/core/widgets/cards/store_product_card.dart';
import 'package:kc_connect/core/widgets/common/app_fab.dart';
import 'package:kc_connect/core/widgets/loading_indicator.dart';
import 'package:kc_connect/core/widgets/empty_state.dart';
import 'package:kc_connect/features/auth/controllers/auth_controller.dart';
import 'package:kc_connect/features/kstore/controllers/store_controller.dart';
import 'package:kc_connect/features/kstore/presentation/widgets/add_product_modal.dart';
import 'package:kc_connect/features/kstore/presentation/widgets/product_detail_dialog.dart';
import 'package:kc_connect/core/widgets/search_bar.dart';

class KstorePage extends StatelessWidget {
  KstorePage({super.key});

  final StoreController controller = Get.put(StoreController());

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Material(
          color: AppColors.backgroundColor,
          child: SafeArea(
            child: Column(
              children: [
                _buildPriceBannerCarousel(),
                const SizedBox(height: 16),
                _buildListingsHeaderWithSearch(),
                const SizedBox(height: 16),
                Expanded(child: _buildProductGrid()),
              ],
            ),
          ),
        ),
        Positioned(
          right: 20,
          bottom: 35,
          child: Obx(() {
            final role =
                Get.find<AuthController>().currentUser?['role'] as String? ??
                '';
            if (role != 'admin') return const SizedBox.shrink();
            return AppFAB(
              onPressed: () => showAddProductModal(context),
              tooltip: 'Add Product',
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPriceBannerCarousel() {
    return CarouselWidget(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      autoPlay: true,
      autoPlayDuration: const Duration(seconds: 5),
      showIndicators: true,
      items: [
        _buildPriceBanner(
          icon: Icons.checkroom,
          label: 'KC T-SHIRTS',
          originalPrice: 'XAF 5,500',
          salePrice: 'XAF 3,500',
          badge: 'HOT DEAL',
        ),
        _buildPriceBanner(
          icon: Icons.dry_cleaning,
          label: 'KC HOODIES',
          originalPrice: 'XAF 12,000',
          salePrice: 'XAF 8,500',
          badge: 'NEW',
        ),
        _buildPriceBanner(
          icon: Icons.menu_book,
          label: 'TEXTBOOKS',
          originalPrice: 'XAF 7,000',
          salePrice: 'XAF 4,999',
          badge: 'SALE',
        ),
      ],
    );
  }

  Widget _buildPriceBanner({
    required IconData icon,
    required String label,
    required String originalPrice,
    required String salePrice,
    required String badge,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: AppColors.gradientColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Left: icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.white, size: 28),
          ),
          const SizedBox(width: 16),
          // Middle: label + prices
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Strikethrough original price
                    Flexible(
                      child: Text(
                        originalPrice,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.white.withValues(alpha: 0.65),
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: AppColors.white.withValues(alpha: 0.65),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Highlighted sale price
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          salePrice,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Right: badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.deepRed,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badge,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingsHeaderWithSearch() {
    return SearchBarWidget(
      hintText: 'Search Products',
      onChanged: (value) => controller.searchProducts(value),
    );
  }

  Widget _buildProductGrid() {
    return Obx(() {
      if (controller.isLoading) {
        return const LoadingIndicator();
      }

      if (controller.filteredProducts.isEmpty) {
        return EmptyState(
          icon: Icons.shopping_bag_outlined,
          title: 'No Products Found',
          message: 'Try adjusting your search or filters',
          action:
              controller.searchQuery.isNotEmpty ||
                  controller.selectedCategory != 'All'
              ? TextButton(
                  onPressed: () => controller.resetFilters(),
                  child: Text(
                    'Clear Filters',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 50),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: controller.filteredProducts.length,
        itemBuilder: (context, index) {
          final product = controller.filteredProducts[index];
          return StoreProductCard(
            imageUrl: product.imageUrl,
            title: product.title,
            price: product.formattedPrice,
            tag: product.isNew ? 'New' : null,
            showTag: product.isNew,
            onTap: () => ProductDetailDialog.show(product),
          );
        },
      );
    });
  }
}
