import 'package:flutter/material.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/bottom_nav_bar.dart';
import 'package:kc_connect/core/widgets/buttons/outlined_button.dart';
import 'package:kc_connect/core/widgets/buttons/primary_button.dart';
import 'package:kc_connect/core/widgets/cards/store_product_card.dart';
import 'package:kc_connect/core/widgets/cards/kc_list_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          Text(
            'bradford',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.gradientColor.colors.last,
            ),
          ),
          PrimaryButton(label: 'Get Started', onPressed: () {}),
          OutlineButtonWidget(label: 'outlined', onPressed: () {}),
          KCListCard(
            title: 'we are all good',
            subtitle: 'subtitle',
            meta: 'Nov 23. sir Caleb',
          ),
          StoreProductCard(
            imageUrl: 'assets/images/kc-connect_icon.png',
            title: 'ww',
            price: '\$20',
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
