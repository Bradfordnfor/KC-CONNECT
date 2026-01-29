import 'package:flutter/material.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/buttons/outlined_button.dart';
import 'package:kc_connect/core/widgets/buttons/primary_button.dart';
import 'package:kc_connect/core/widgets/cards/store_product_card.dart';
import 'package:kc_connect/core/widgets/cards/kc_list_card.dart';
import 'package:kc_connect/core/widgets/loading_indicator.dart';
import 'package:kc_connect/core/widgets/search_bar.dart';
import 'package:kc_connect/core/widgets/carousel_widget.dart';
import 'package:kc_connect/core/widgets/cards/alumni_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundColor,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
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
                tag: 'Resource',
                rightWidget: PrimaryButton(label: 'Join', onPressed: () {}),
                imageUrl: 'assets/images/kc-connect_icon.png',
                title: 'we are all good',
                subtitle: 'subtitle',
                meta: 'Nov 23. sir Caleb',
              ),
              StoreProductCard(
                imageUrl: 'assets/images/kc-connect_icon.png',
                title: 'wwtyui',
                price: '\$20',
                showTag: true,
                tag: 'New',
              ),
              AlumniCard(
                name: 'Nyake Tudora',
                role: 'Software Engineering student',
                school: 'U.B(C.O.T), Cameroon',
                classInfo: 'Class of 2020',
                imageUrl: 'assets/images/kc-connect_icon.png',
              ),
              LoadingIndicator(size: 50),
              SearchBarWidget(hintText: 'Search'),
              CarouselWidget(
                items: [
                  Container(color: Colors.red),
                  Container(color: Colors.blue),
                  Image.asset('assets/images/kc-connect_icon.png'),
                  Container(color: Colors.purple),
                ],
                height: 200,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
