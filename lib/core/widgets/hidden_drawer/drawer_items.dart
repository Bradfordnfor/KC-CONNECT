// lib/core/widgets/hidden_drawer/drawer_items.dart
import 'package:flutter/material.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';

import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';

import 'package:kc_connect/features/home/presentation/screens/home_page.dart';
import 'package:kc_connect/features/alumni/presentation/screens/alumni_page.dart';
import 'package:kc_connect/features/notifications/presentation/screens/news_page.dart';

final List<ScreenHiddenDrawer> drawerItems = [
  ScreenHiddenDrawer(
    ItemHiddenMenu(
      name: "Home",
      baseStyle: AppTextStyles.body.copyWith(color: AppColors.white),
      selectedStyle: AppTextStyles.body.copyWith(color: AppColors.white),
      colorLineSelected: AppColors.red,
    ),
    const HomePage(),
  ),

  // ---------- ALUMNI (index 2) ----------
  ScreenHiddenDrawer(
    ItemHiddenMenu(
      name: "Alumni",
      baseStyle: AppTextStyles.body.copyWith(color: AppColors.white),
      selectedStyle: AppTextStyles.body.copyWith(color: AppColors.white),
      colorLineSelected: AppColors.red,
    ),
    const AlumniPage(),
  ),

  // ---------- NEWS (index 3) ----------
  ScreenHiddenDrawer(
    ItemHiddenMenu(
      name: "News",
      baseStyle: AppTextStyles.body.copyWith(color: AppColors.white),
      selectedStyle: AppTextStyles.body.copyWith(color: AppColors.white),
      colorLineSelected: AppColors.red,
    ),
    const NewsPage(),
  ),
];

class _HeaderPage extends StatelessWidget {
  const _HeaderPage({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
