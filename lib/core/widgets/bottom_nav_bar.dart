import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: AppColors.blue,
        buttonBackgroundColor: AppColors.red,
        animationDuration: Duration(milliseconds: 300),
        items: [
          CurvedNavigationBarItem(
            child: Icon(Icons.home, size: 30, color: AppColors.white),
            label: 'Home',
            labelStyle: AppTextStyles.caption.copyWith(color: AppColors.white),
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.book, size: 30, color: AppColors.white),
            label: 'Resources',
            labelStyle: AppTextStyles.caption.copyWith(color: AppColors.white),
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.book, size: 30, color: AppColors.white),
            label: 'Learn',
            labelStyle: AppTextStyles.caption.copyWith(color: AppColors.white),
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.event, size: 30, color: AppColors.white),
            label: 'Events',
            labelStyle: AppTextStyles.caption.copyWith(color: AppColors.white),
          ),
          CurvedNavigationBarItem(
            child: Icon(
              Icons.shopping_basket,
              size: 30,
              color: AppColors.white,
            ),
            label: 'K-Store',
            labelStyle: AppTextStyles.caption.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }
}
