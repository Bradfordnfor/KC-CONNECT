// lib/features/alumni/presentation/screens/alumni_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/routes/app_routes.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/carousel_widget.dart';
import 'package:kc_connect/core/widgets/cards/alumni_card.dart';
import 'package:kc_connect/features/alumni/controllers/alumni_controller.dart';
import 'package:kc_connect/features/payment/presentation/widgets/subscription_payment_modal.dart';

class AlumniPage extends StatelessWidget {
  const AlumniPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AlumniController());

    return Material(
      color: AppColors.backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBannerCarousel(),
                    _buildListingsHeaderWithSearch(controller),
                    const SizedBox(height: 16),
                    _buildAlumniList(controller),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerCarousel() {
    return CarouselWidget(
      margin: const EdgeInsets.all(16),
      height: 155,
      autoPlay: false,
      showIndicators: false,
      items: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.gradientColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                'FIND A MENTOR',
                style: AppTextStyles.subHeading.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildIconBadge(Icons.star, 1),
                      const SizedBox(height: 10),
                      _buildIconBadge(Icons.star, 2),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Connect with experienced KC alumni who can guide your journey',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.white,
                            fontSize: 11,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Get personalized advice and mentorship support',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.white,
                            fontSize: 11,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconBadge(IconData icon, int number) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, color: AppColors.white, size: 18),
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: AppColors.blue,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number.toString(),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingsHeaderWithSearch(AlumniController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.tune, color: AppColors.blue, size: 24),
          const SizedBox(width: 8),
          Text(
            'Listings',
            style: AppTextStyles.subHeading.copyWith(
              color: AppColors.blue,
              fontSize: 20,
            ),
          ),
          const SizedBox(width: 30),
          Expanded(
            child: Container(
              height: 35,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: controller.searchAlumni,
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: AppTextStyles.body.copyWith(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.blue,
                    size: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                  isDense: true,
                ),
                style: AppTextStyles.body.copyWith(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlumniList(AlumniController controller) {
    return Obx(() {
      if (controller.isLoading) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(color: AppColors.blue),
          ),
        );
      }

      if (controller.filteredAlumni.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                Icon(Icons.people_outline,
                    size: 64, color: AppColors.blue.withValues(alpha: 0.4)),
                const SizedBox(height: 16),
                Text(
                  'No alumni found',
                  style: AppTextStyles.subHeading
                      .copyWith(color: AppColors.blue),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.filteredAlumni.length,
        itemBuilder: (context, index) {
          final alumni = controller.filteredAlumni[index];
          return AlumniCard(
            imageUrl: alumni.imageUrl,
            name: alumni.name,
            role: alumni.role,
            school: alumni.school,
            classInfo: alumni.classInfo,
            onTap: () {
              if (checkSubscriptionGate()) return;
              Get.toNamed(AppRoutes.alumniDetail, arguments: alumni.toMap());
            },
          );
        },
      );
    });
  }
}
