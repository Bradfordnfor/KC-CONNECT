// lib/features/store/controllers/store_controller.dart
import 'package:get/get.dart';
import 'package:kc_connect/core/models/product_model.dart';

class StoreController extends GetxController {
  // Reactive state
  final _products = <ProductModel>[].obs;
  final _filteredProducts = <ProductModel>[].obs;
  final _selectedCategory = 'All'.obs;
  final _searchQuery = ''.obs;
  final _isLoading = false.obs;
  final _cartItems = <String, int>{}.obs; // productId -> quantity

  // Getters
  List<ProductModel> get products => _products;
  List<ProductModel> get filteredProducts => _filteredProducts;
  String get selectedCategory => _selectedCategory.value;
  String get searchQuery => _searchQuery.value;
  bool get isLoading => _isLoading.value;
  int get cartItemCount => _cartItems.values.fold(0, (sum, qty) => sum + qty);

  @override
  /*************  ✨ Windsurf Command ⭐  *************/
  /// Called when the controller is initialized.
  /// Loads mock products into the [_products] list
  /// and sets [_isLoading] to true until the data is loaded.
  /*******  ef635e7b-20aa-45c4-9a8c-02d4e81523ae  *******/
  void onInit() {
    super.onInit();
    _loadMockProducts();
  }

  // Load mock products
  void _loadMockProducts() {
    _isLoading.value = true;

    // Mock data - replace with Supabase later
    _products.value = [
      ProductModel.mock(id: '1', title: 'KC T-SHIRT', price: 4999),
      ProductModel.mock(id: '2', title: 'KC T-SHIRT', price: 4999),
      ProductModel.mock(id: '3', title: 'KC T-SHIRT', price: 4999),
      ProductModel.mock(id: '4', title: 'KC T-SHIRT', price: 4999),
      ProductModel.mock(id: '5', title: 'KC T-SHIRT', price: 4999),
      ProductModel.mock(id: '6', title: 'KC T-SHIRT', price: 4999),
      ProductModel.mock(id: '7', title: 'KC HOODIE', price: 7999),
      ProductModel.mock(id: '8', title: 'KC CAP', price: 2999),
    ];

    _filteredProducts.value = _products;
    _isLoading.value = false;
  }

  // Search products
  void searchProducts(String query) {
    _searchQuery.value = query.toLowerCase();
    _filterProducts();
  }

  // Filter by category
  void filterByCategory(String category) {
    _selectedCategory.value = category;
    _filterProducts();
  }

  // Apply filters
  void _filterProducts() {
    var filtered = _products.toList();

    // Filter by category
    if (_selectedCategory.value != 'All') {
      filtered = filtered
          .where((p) => p.category == _selectedCategory.value)
          .toList();
    }

    // Filter by search query
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

  // Add to cart
  void addToCart(String productId) {
    if (_cartItems.containsKey(productId)) {
      _cartItems[productId] = _cartItems[productId]! + 1;
    } else {
      _cartItems[productId] = 1;
    }
    _cartItems.refresh();

    Get.snackbar(
      'Added to Cart',
      'Product added successfully',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Get cart quantity for product
  int getCartQuantity(String productId) {
    return _cartItems[productId] ?? 0;
  }

  // Clear cart
  void clearCart() {
    _cartItems.clear();
  }

  // Reset filters
  void resetFilters() {
    _selectedCategory.value = 'All';
    _searchQuery.value = '';
    _filteredProducts.value = _products;
  }
}
