import 'package:flutter/material.dart';
import 'package:kc_connect/core/theme/app_colors.dart';

/// Uniform Floating Action Button component
///
/// Usage:
/// ```dart
/// floatingActionButton: AppFAB(
///   onPressed: () => showAddEventModal(),
///   tooltip: 'Add Event',
/// ),
/// ```
class AppFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  const AppFAB({
    Key? key,
    required this.onPressed,
    this.icon = Icons.add,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
    this.size = 56,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? AppColors.red,
      tooltip: tooltip,
      elevation: 4,
      highlightElevation: 8,
      heroTag: null,
      child: Icon(icon, color: iconColor ?? AppColors.white, size: 30),
    );
  }
}

/// Extended FAB with label
class AppFABExtended extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppFABExtended({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? AppColors.blue,
      elevation: 4,
      highlightElevation: 8,
      heroTag: null,
      icon: Icon(icon, color: foregroundColor ?? AppColors.white),
      label: Text(
        label,
        style: TextStyle(
          color: foregroundColor ?? AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
