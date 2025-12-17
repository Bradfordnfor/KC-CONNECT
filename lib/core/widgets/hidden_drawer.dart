import 'package:flutter/material.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/features/alumni/presentation/screens/alumni_page.dart';
import 'package:kc_connect/features/notifications/presentation/screens/news_page.dart';

class HiddenDrawer extends StatefulWidget {
  const HiddenDrawer({super.key});

  @override
  State<HiddenDrawer> createState() => _HiddenDrawerState();
}

class _HiddenDrawerState extends State<HiddenDrawer> {
  @override
  Widget build(BuildContext context) {
    return HiddenDrawerMenu(
      screens: [
        ScreenHiddenDrawer(
          ItemHiddenMenu(
            name: 'Alumni',
            baseStyle: AppTextStyles.body.copyWith(color: AppColors.white),
            selectedStyle: TextStyle(),
            colorLineSelected: AppColors.red,
          ),
          AlumniPage(),
        ),
        ScreenHiddenDrawer(
          ItemHiddenMenu(
            name: 'News',
            baseStyle: AppTextStyles.body.copyWith(color: AppColors.white),
            selectedStyle: TextStyle(),
            colorLineSelected: AppColors.red,
          ),
          NewsPage(),
        ),
      ],
      withAutoTittleName: false,
      backgroundColorAppBar: AppColors.white,
      backgroundColorMenu: AppColors.blue,
      typeOpen: TypeOpen.FROM_RIGHT,
    );
  }
}
