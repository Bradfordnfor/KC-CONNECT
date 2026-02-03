// lib/features/store/presentation/screens/store_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/carousel_widget.dart';
import 'package:kc_connect/core/widgets/cards/store_product_card.dart';
import 'package:kc_connect/core/widgets/loading_indicator.dart';
import 'package:kc_connect/core/widgets/empty_state.dart';
import 'package:kc_connect/features/kstore/controllers/store_controller.dart';
import 'package:kc_connect/features/kstore/presentation/widgets/product_detail_dialog.dart';
import 'package:kc_connect/core/widgets/search_bar.dart';

class KstorePage extends StatelessWidget {
  KstorePage({super.key});

  final StoreController controller = Get.put(StoreController());

  @override
  Widget build(BuildContext context) {
    return Material(
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
        _buildPriceBanner('XAF 5500', 'XAF 3500'),
        _buildPriceBanner('XAF 7999', 'XAF 5999'),
        _buildPriceBanner('XAF 4500', 'XAF 2999'),
      ],
    );
  }

  Widget _buildPriceBanner(String price1, String price2) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: AppColors.gradientColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title
          Text(
            'KC-TSHIRTS',
            style: AppTextStyles.subHeading.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),

          // Price indicators (dots with prices)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPriceDot(price1),
              const SizedBox(width: 16),
              _buildPriceDot(price2),
              const SizedBox(width: 16),
              _buildPriceDot(''),
              const SizedBox(width: 16),
              _buildPriceDot(''),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDot(String price) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: price.isEmpty
                ? AppColors.white.withOpacity(0.5)
                : AppColors.white,
            shape: BoxShape.circle,
          ),
        ),
        if (price.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            price,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
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
