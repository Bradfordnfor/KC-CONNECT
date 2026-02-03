// lib/features/store/presentation/widgets/product_detail_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/models/product_model.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/buttons/primary_button.dart';
import 'package:kc_connect/features/kstore/controllers/store_controller.dart';

class ProductDetailDialog extends StatelessWidget {
  final ProductModel product;

  const ProductDetailDialog({super.key, required this.product});

  static void show(ProductModel product) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: ProductDetailDialog(product: product),
      ),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final storeController = Get.find<StoreController>();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () => Get.back(),
              padding: const EdgeInsets.all(16),
            ),
          ),

          // Product Image
          Flexible(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 160),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: product.imageUrl.startsWith('http')
                    ? Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      )
                    : Image.asset(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title and Price Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Expanded(
                      child: Text(
                        product.title,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Price Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD4D4), // Light pink/red
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        product.formattedPrice,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.deepRed,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  product.description,
                  style: AppTextStyles.body.copyWith(
                    color: Colors.grey[700],
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                // Purchase Button
                PrimaryButton(
                  label: 'Purchase now',
                  expanded: true,
                  height: 48,
                  onPressed: () {
                    storeController.addToCart(product.id);
                    Get.back();

                    // Show success message
                    Get.snackbar(
                      'Success',
                      'Added to cart successfully!',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.blue,
                      colorText: AppColors.white,
                      margin: const EdgeInsets.all(16),
                      borderRadius: 8,
                      duration: const Duration(seconds: 2),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.backgroundColor,
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 64, color: AppColors.blue),
      ),
    );
  }
}
