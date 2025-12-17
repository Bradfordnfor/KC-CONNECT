import 'package:flutter/material.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'drawer_items.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';

class HiddenDrawerMenuUI extends StatelessWidget {
  final List<ScreenHiddenDrawer> screens;

  const HiddenDrawerMenuUI({super.key, required this.screens});

  @override
  Widget build(BuildContext context) {
    return HiddenDrawerMenu(
      screens: screens,
      initPositionSelected: 0,
      backgroundColorMenu: AppColors.blue,
      slidePercent: 60,
      typeOpen: TypeOpen.FROM_LEFT,
      styleAutoTittleName: AppTextStyles.subHeading.copyWith(
        color: AppColors.deepRed,
      ),
      isTitleCentered: true,

      // These are valid in v3.0.1
      leadingAppBar: Icon(Icons.menu, color: AppColors.deepRed),

      actionsAppBar: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Image.asset('assets/images/kc-connect_icon.png', height: 64),
        ),
      ],
      backgroundColorAppBar: Colors.white,
    );
  }
}
