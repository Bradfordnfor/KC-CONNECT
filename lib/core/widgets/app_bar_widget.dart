import 'package:flutter/material.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const AppBarWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTextStyles.subHeading.copyWith(color: AppColors.deepRed),
      ),
      leading: Image.asset('assets/images/kc-connect_icon.png'),
      actions: [
        IconButton(
          icon: const Icon(Icons.menu, color: AppColors.blue),
          onPressed: () {
            Scaffold.of(context).openEndDrawer();
          },
        ),
      ],
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
