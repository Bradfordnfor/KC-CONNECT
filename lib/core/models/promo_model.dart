import 'package:flutter/material.dart';

class PromoModel {
  final String id;
  final String label;
  final String originalPrice;
  final String salePrice;
  final String badge;
  final String iconName;
  final bool isActive;

  PromoModel({
    required this.id,
    required this.label,
    required this.originalPrice,
    required this.salePrice,
    required this.badge,
    required this.iconName,
    this.isActive = true,
  });

  factory PromoModel.fromJson(Map<String, dynamic> j) => PromoModel(
        id: j['id'] as String,
        label: j['label'] as String,
        originalPrice: j['original_price'] as String,
        salePrice: j['sale_price'] as String,
        badge: j['badge'] as String? ?? 'NEW',
        iconName: j['icon_name'] as String? ?? 'checkroom',
        isActive: j['is_active'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'label': label,
        'original_price': originalPrice,
        'sale_price': salePrice,
        'badge': badge,
        'icon_name': iconName,
        'is_active': isActive,
      };

  static const Map<String, IconData> iconMap = {
    'checkroom': Icons.checkroom,
    'dry_cleaning': Icons.dry_cleaning,
    'menu_book': Icons.menu_book,
    'laptop': Icons.laptop,
    'school': Icons.school,
    'backpack': Icons.backpack,
    'headphones': Icons.headphones,
    'shopping_bag': Icons.shopping_bag,
    'star': Icons.star,
    'local_offer': Icons.local_offer,
    'sports_soccer': Icons.sports_soccer,
    'devices': Icons.devices,
  };

  static IconData iconData(String name) => iconMap[name] ?? Icons.local_offer;
}
