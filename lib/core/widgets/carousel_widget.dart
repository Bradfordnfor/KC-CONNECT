// lib/core/widgets/carousel_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kc_connect/core/theme/app_colors.dart';

/// Reusable carousel widget with auto-play functionality
///
/// Usage:
/// ```dart
/// CarouselWidget(
///   items: [
///     Container(color: Colors.red),
///     Container(color: Colors.blue),
///   ],
///   height: 200,
/// )
/// ```
class CarouselWidget extends StatefulWidget {
  /// List of widgets to display in carousel
  final List<Widget> items;

  /// Height of the carousel
  final double height;

  /// Whether to auto-play (only works when items.length > 1)
  final bool autoPlay;

  /// Duration between auto-play transitions
  final Duration autoPlayDuration;

  /// Whether to show page indicators (dots)
  final bool showIndicators;

  /// Margin around the carousel
  final EdgeInsets? margin;

  /// Border radius for carousel items
  final double borderRadius;

  /// Callback when page changes
  final ValueChanged<int>? onPageChanged;

  const CarouselWidget({
    super.key,
    required this.items,
    this.height = 200,
    this.autoPlay = true,
    this.autoPlayDuration = const Duration(seconds: 4),
    this.showIndicators = true,
    this.margin,
    this.borderRadius = 16,
    this.onPageChanged,
  });

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  // For infinite scrolling, we start at a high number
  static const int _initialPage = 10000;

  @override
  void initState() {
    super.initState();

    // Initialize controller at middle position for infinite scroll
    _pageController = PageController(
      initialPage: widget.items.length > 1 ? _initialPage : 0,
    );

    // Only start auto-play if there's more than one item
    if (widget.autoPlay && widget.items.length > 1) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(widget.autoPlayDuration, (timer) {
      if (_pageController.hasClients && mounted) {
        // Always move forward - this creates the seamless loop
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  int _getRealIndex(int position) {
    return position % widget.items.length;
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If no items, return empty space
    if (widget.items.isEmpty) {
      return SizedBox(height: widget.height);
    }

    // If only one item, don't use PageView
    if (widget.items.length == 1) {
      return Container(
        height: widget.height,
        margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: widget.items.first,
        ),
      );
    }

    return Column(
      children: [
        Container(
          height: widget.height,
          margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16),
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              final realIndex = _getRealIndex(index);
              setState(() {
                _currentPage = realIndex;
              });
              widget.onPageChanged?.call(realIndex);
            },
            // Infinite items by using a very large itemCount
            itemCount: widget.items.length > 1 ? 20000 : widget.items.length,
            itemBuilder: (context, index) {
              final realIndex = _getRealIndex(index);
              return ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: widget.items[realIndex],
              );
            },
          ),
        ),
        if (widget.showIndicators && widget.items.length > 1) ...[
          const SizedBox(height: 12),
          _buildIndicators(),
        ],
      ],
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.items.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: _currentPage == index
                ? AppColors.red
                : AppColors.blue.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}
