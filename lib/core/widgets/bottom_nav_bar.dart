import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;
  final int unreadChatCount;

  const BottomNavBar({
    super.key,
    this.currentIndex = 0,
    this.onTap,
    this.unreadChatCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CurvedNavigationBar(
        index: currentIndex,
        backgroundColor: Colors.transparent,
        color: AppColors.blue,
        buttonBackgroundColor: AppColors.red,
        animationDuration: const Duration(milliseconds: 300),
        onTap: onTap,
        items: [
          CurvedNavigationBarItem(
            child: const Icon(Icons.home, size: 30, color: AppColors.white),
            label: 'Home',
            labelStyle: AppTextStyles.caption.copyWith(color: AppColors.white),
          ),
          CurvedNavigationBarItem(
            child: const Icon(Icons.book, size: 30, color: AppColors.white),
            label: 'Resources',
            labelStyle: AppTextStyles.caption.copyWith(color: AppColors.white),
          ),
          CurvedNavigationBarItem(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.chat, size: 30, color: AppColors.white),
                if (unreadChatCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        unreadChatCount > 99 ? '99+' : '$unreadChatCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Learn',
            labelStyle: AppTextStyles.caption.copyWith(color: AppColors.white),
          ),
          CurvedNavigationBarItem(
            child: const Icon(Icons.event, size: 30, color: AppColors.white),
            label: 'Events',
            labelStyle: AppTextStyles.caption.copyWith(color: AppColors.white),
          ),
          CurvedNavigationBarItem(
            child: const Icon(
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
