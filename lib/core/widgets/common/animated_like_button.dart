import 'package:flutter/material.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';

/// Animated like button for alumni profiles
///
/// Usage:
/// ```dart
/// AppLikeButton(
///   isLiked: true,
///   likeCount: 24,
///   onTap: () => controller.toggleLike(alumniId),
/// )
/// ```
class AppLikeButton extends StatefulWidget {
  final bool isLiked;
  final int likeCount;
  final VoidCallback onTap;
  final bool showCount;
  final double iconSize;

  const AppLikeButton({
    Key? key,
    required this.isLiked,
    required this.likeCount,
    required this.onTap,
    this.showCount = true,
    this.iconSize = 20,
  }) : super(key: key);

  @override
  State<AppLikeButton> createState() => _AppLikeButtonState();
}

class _AppLikeButtonState extends State<AppLikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Icon(
              widget.isLiked ? Icons.favorite : Icons.favorite_border,
              color: widget.isLiked ? AppColors.red : AppColors.textSecondary,
              size: widget.iconSize,
            ),
          ),
          if (widget.showCount && widget.likeCount > 0) ...[
            const SizedBox(width: 4),
            Text(
              '${widget.likeCount}',
              style: AppTextStyles.body.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Icon-only like button (for cards)
class AppLikeIcon extends StatefulWidget {
  final bool isLiked;
  final VoidCallback onTap;
  final double size;

  const AppLikeIcon({
    Key? key,
    required this.isLiked,
    required this.onTap,
    this.size = 24,
  }) : super(key: key);

  @override
  State<AppLikeIcon> createState() => _AppLikeIconState();
}

class _AppLikeIconState extends State<AppLikeIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Icon(
          widget.isLiked ? Icons.favorite : Icons.favorite_border,
          color: widget.isLiked ? AppColors.red : AppColors.textSecondary,
          size: widget.size,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
