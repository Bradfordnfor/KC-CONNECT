// lib/core/models/product_model.dart

class ProductModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isNew;
  final List<String> sizes;
  final List<String> colors;
  final int stock;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isNew = false,
    this.sizes = const [],
    this.colors = const [],
    this.stock = 0,
  });

  // Format price as XAF currency
  String get formattedPrice => 'XAF ${price.toStringAsFixed(0)}';

  // Copy with method for updates
  ProductModel copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    bool? isNew,
    List<String>? sizes,
    List<String>? colors,
    int? stock,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isNew: isNew ?? this.isNew,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      stock: stock ?? this.stock,
    );
  }

  // Mock data factory
  factory ProductModel.mock({
    required String id,
    String title = 'KC T-SHIRT',
    double price = 4999,
  }) {
    return ProductModel(
      id: id,
      title: title,
      description:
          'Grab your official KC T-shirt — where style meets purpose. Made for thinkers, creators, and changemakers. Available now in all sizes and colors.',
      price: price,
      imageUrl: 'assets/images/kc-connect_icon.png',
      category: 'T-Shirts',
      isNew: true,
      sizes: ['S', 'M', 'L', 'XL', 'XXL'],
      colors: ['Blue', 'Yellow', 'Black', 'White'],
      stock: 50,
    );
  }
}
