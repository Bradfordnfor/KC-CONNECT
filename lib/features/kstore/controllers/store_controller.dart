// lib/features/store/controllers/store_controller.dart
import 'package:get/get.dart';
import 'package:kc_connect/core/models/product_model.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoreController extends GetxController {
  final _products = <ProductModel>[].obs;
  final _filteredProducts = <ProductModel>[].obs;
  final _selectedCategory = 'All'.obs;
  final _searchQuery = ''.obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final _cartItems = <String, int>{}.obs; // productId -> quantity

  List<ProductModel> get products => _products;
  List<ProductModel> get filteredProducts => _filteredProducts;
  String get selectedCategory => _selectedCategory.value;
  String get searchQuery => _searchQuery.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  int get cartItemCount => _cartItems.values.fold(0, (sum, qty) => sum + qty);

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await Supabase.instance.client
          .from('products')
          .select()
          .eq('status', 'active')
          .order('created_at', ascending: false);

      _products.value =
          (response as List).map((r) => _fromRow(r as Map<String, dynamic>)).toList();
      _filterProducts();
      _isLoading.value = false;
    } catch (e) {
      _errorMessage.value = 'Failed to load products';
      _isLoading.value = false;
    }
  }

  void searchProducts(String query) {
    _searchQuery.value = query.toLowerCase();
    _filterProducts();
  }

  void filterByCategory(String category) {
    _selectedCategory.value = category;
    _filterProducts();
  }

  void _filterProducts() {
    var filtered = _products.toList();

    if (_selectedCategory.value != 'All') {
      filtered = filtered
          .where((p) => p.category == _selectedCategory.value)
          .toList();
    }

    if (_searchQuery.value.isNotEmpty) {
      filtered = filtered
          .where(
            (p) =>
                p.title.toLowerCase().contains(_searchQuery.value) ||
                p.description.toLowerCase().contains(_searchQuery.value),
          )
          .toList();
    }

    _filteredProducts.value = filtered;
  }

  List<String> getAvailableCategories() {
    final categories = _products.map((p) => p.category).toSet().toList()..sort();
    categories.insert(0, 'All');
    return categories;
  }

  void addToCart(String productId) {
    if (_cartItems.containsKey(productId)) {
      _cartItems[productId] = _cartItems[productId]! + 1;
    } else {
      _cartItems[productId] = 1;
    }
    _cartItems.refresh();
    AppSnackbar.success('Added to Cart', 'Product added successfully');
  }

  int getCartQuantity(String productId) => _cartItems[productId] ?? 0;

  void clearCart() => _cartItems.clear();

  Future<void> refreshProducts() => loadProducts();

  void resetFilters() {
    _selectedCategory.value = 'All';
    _searchQuery.value = '';
    _filteredProducts.value = _products;
  }

  // ─── Mapper ─────────────────────────────────────────────────────────────────

  ProductModel _fromRow(Map<String, dynamic> r) {
    final sizes =
        (r['sizes'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final colors =
        (r['colors'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final createdAt = DateTime.tryParse(r['created_at'] ?? '');
    final isRecent = createdAt != null &&
        DateTime.now().difference(createdAt).inDays <= 3;

    return ProductModel(
      id: r['id'] ?? '',
      title: r['name'] ?? '',
      description: r['description'] ?? '',
      price: (r['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: r['primary_image_url'] ?? '',
      category: r['category'] ?? 'other',
      isNew: r['is_featured'] == true || isRecent,
      sizes: sizes,
      colors: colors,
      stock: r['stock_quantity'] ?? 0,
    );
  }
}
