import 'package:flutter/material.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';

class OutlineButtonWidget extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double? height;

  const OutlineButtonWidget({
    super.key,
    required this.label,
    this.onPressed,
    this.height = 44,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColors.blue),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: Size(0, height ?? 44),
        padding: const EdgeInsets.symmetric(horizontal: 14),
      ),
      child: Text(
        label,
        style: AppTextStyles.body.copyWith(
          color: AppColors.blue,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
