// lib/features/resources/controllers/resources_controller.dart
import 'package:get/get.dart';
import 'package:kc_connect/core/models/resource_model.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResourcesController extends GetxController {
  // Reactive state
  final _allResources = <ResourceModel>[].obs;
  final _filteredResources = <ResourceModel>[].obs;
  final _currentTabIndex = 0.obs;
  final _searchQuery = ''.obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final _selectedSubject = 'All'.obs;
  final _showFavoritesOnly = false.obs; // NEW: Show favorites filter
  final _favoriteResources =
      <String>[].obs; // NEW: Resource IDs that are favorited

  // Tab categories
  final List<String> categories = [
    'Ordinary Level',
    'Advanced Level',
    'Other Books',
  ];

  // Getters
  List<ResourceModel> get allResources => _allResources;
  List<ResourceModel> get filteredResources => _filteredResources;
  int get currentTabIndex => _currentTabIndex.value;
  String get searchQuery => _searchQuery.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  String get selectedSubject => _selectedSubject.value;
  String get currentCategory => categories[_currentTabIndex.value];
  bool get showFavoritesOnly => _showFavoritesOnly.value;

  @override
  void onInit() {
    super.onInit();
    loadResources();
    loadFavorites();
  }

  // Load resources
  Future<void> loadResources() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Load mock data (replace with Supabase later)
      _allResources.value = ResourceModel.mockList();
      _applyFilters();

      _isLoading.value = false;
    } catch (e) {
      _errorMessage.value = 'Failed to load resources: ${e.toString()}';
      _isLoading.value = false;
    }
  }

  // Load user's favorited resources
  Future<void> loadFavorites() async {
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId == null) return;

      final response = await Supabase.instance.client
          .from('user_favorites')
          .select('resource_id')
          .eq('user_id', currentUserId);

      _favoriteResources.value = (response as List)
          .map((item) => item['resource_id'] as String)
          .toList();
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  // Check if resource is favorited
  bool isFavorited(String resourceId) {
    return _favoriteResources.contains(resourceId);
  }

  // Toggle favorite
  Future<void> toggleFavorite(String resourceId) async {
    try {
      final isCurrentlyFavorited = isFavorited(resourceId);
      final resource = _allResources.firstWhere((r) => r.id == resourceId);

      if (isCurrentlyFavorited) {
        // Remove from favorites
        await _removeFavorite(resourceId);
        _favoriteResources.remove(resourceId);

        AppSnackbar.info('Removed', 'Removed ${resource.title} from favorites');
      } else {
        // Add to favorites
        await _addFavorite(resourceId);
        _favoriteResources.add(resourceId);

        AppSnackbar.success('Added', 'Added ${resource.title} to favorites');
      }

      // Refresh filters in case we're showing favorites only
      _applyFilters();
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to update favorite status');
    }
  }

  // Add resource to favorites (Supabase)
  Future<void> _addFavorite(String resourceId) async {
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId == null) throw Exception('Not authenticated');

      await Supabase.instance.client.from('user_favorites').insert({
        'user_id': currentUserId,
        'resource_id': resourceId,
      });
    } catch (e) {
      throw Exception('Failed to add favorite: $e');
    }
  }

  // Remove resource from favorites (Supabase)
  Future<void> _removeFavorite(String resourceId) async {
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId == null) throw Exception('Not authenticated');

      await Supabase.instance.client
          .from('user_favorites')
          .delete()
          .eq('user_id', currentUserId)
          .eq('resource_id', resourceId);
    } catch (e) {
      throw Exception('Failed to remove favorite: $e');
    }
  }

  // Toggle show favorites only
  void toggleShowFavoritesOnly() {
    _showFavoritesOnly.value = !_showFavoritesOnly.value;
    _applyFilters();
  }

  // Change tab
  void changeTab(int index) {
    if (index != _currentTabIndex.value) {
      _currentTabIndex.value = index;
      _searchQuery.value = ''; // Clear search when changing tabs
      _selectedSubject.value = 'All';
      _showFavoritesOnly.value = false; // Reset favorites filter on tab change
      _applyFilters();
    }
  }

  // Search resources
  void searchResources(String query) {
    _searchQuery.value = query.toLowerCase();
    _applyFilters();
  }

  // Filter by subject
  void filterBySubject(String subject) {
    _selectedSubject.value = subject;
    _applyFilters();
  }

  // Apply all filters
  void _applyFilters() {
    var filtered = _allResources.toList();

    // Filter by current tab category
    final category = currentCategory;
    filtered = filtered.where((r) => r.category == category).toList();

    // Filter by favorites if enabled
    if (_showFavoritesOnly.value) {
      filtered = filtered.where((r) => isFavorited(r.id)).toList();
    }

    // Filter by subject if not "All"
    if (_selectedSubject.value != 'All') {
      filtered = filtered
          .where((r) => r.subject == _selectedSubject.value)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.value.isNotEmpty) {
      filtered = filtered.where((r) {
        return r.title.toLowerCase().contains(_searchQuery.value) ||
            r.description.toLowerCase().contains(_searchQuery.value) ||
            (r.subject?.toLowerCase().contains(_searchQuery.value) ?? false);
      }).toList();
    }

    _filteredResources.value = filtered;
  }

  // Get available subjects for current category
  List<String> getAvailableSubjects() {
    final category = currentCategory;
    final subjects = _allResources
        .where((r) => r.category == category && r.subject != null)
        .map((r) => r.subject!)
        .toSet()
        .toList();
    subjects.insert(0, 'All');
    return subjects;
  }

  // Download resource
  Future<void> downloadResource(ResourceModel resource) async {
    try {
      AppSnackbar.info('Downloading', 'Downloading ${resource.title}...');

      // Simulate download (replace with actual download logic)
      await Future.delayed(const Duration(seconds: 1));

      // Update download count
      final index = _allResources.indexWhere((r) => r.id == resource.id);
      if (index != -1) {
        _allResources[index] = resource.copyWith(
          downloads: resource.downloads + 1,
        );
      }

      AppSnackbar.success(
        'Success',
        '${resource.title} downloaded successfully',
      );
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to download resource');
    }
  }

  // Refresh resources
  Future<void> refreshResources() async {
    await loadResources();
    await loadFavorites();
  }

  // Reset filters
  void resetFilters() {
    _searchQuery.value = '';
    _selectedSubject.value = 'All';
    _showFavoritesOnly.value = false;
    _applyFilters();
  }

  // Get resource count for category
  int getResourceCountForCategory(String category) {
    return _allResources.where((r) => r.category == category).length;
  }

  // Get favorites count
  int getFavoritesCount() {
    return _favoriteResources.length;
  }
}
