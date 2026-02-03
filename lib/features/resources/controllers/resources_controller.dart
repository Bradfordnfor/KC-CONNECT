// lib/features/resources/controllers/resources_controller.dart
import 'package:get/get.dart';
import 'package:kc_connect/core/models/resource_model.dart';

class ResourcesController extends GetxController {
  // Reactive state
  final _allResources = <ResourceModel>[].obs;
  final _filteredResources = <ResourceModel>[].obs;
  final _currentTabIndex = 0.obs;
  final _searchQuery = ''.obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final _selectedSubject = 'All'.obs;

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

  @override
  void onInit() {
    super.onInit();
    loadResources();
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

  // Change tab
  void changeTab(int index) {
    if (index != _currentTabIndex.value) {
      _currentTabIndex.value = index;
      _searchQuery.value = ''; // Clear search when changing tabs
      _selectedSubject.value = 'All';
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

  // Toggle favorite
  void toggleFavorite(String resourceId) {
    final index = _allResources.indexWhere((r) => r.id == resourceId);
    if (index != -1) {
      final resource = _allResources[index];
      _allResources[index] = resource.copyWith(
        isFavorite: !resource.isFavorite,
      );
      _applyFilters();

      Get.snackbar(
        resource.isFavorite ? 'Removed from favorites' : 'Added to favorites',
        resource.title,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Download resource
  Future<void> downloadResource(ResourceModel resource) async {
    try {
      Get.snackbar(
        'Downloading',
        'Downloading ${resource.title}...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      // Simulate download (replace with actual download logic)
      await Future.delayed(const Duration(seconds: 1));

      // Update download count
      final index = _allResources.indexWhere((r) => r.id == resource.id);
      if (index != -1) {
        _allResources[index] = resource.copyWith(
          downloads: resource.downloads + 1,
        );
      }

      Get.snackbar(
        'Success',
        '${resource.title} downloaded successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download resource',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Refresh resources
  Future<void> refreshResources() async {
    await loadResources();
  }

  // Reset filters
  void resetFilters() {
    _searchQuery.value = '';
    _selectedSubject.value = 'All';
    _applyFilters();
  }

  // Get resource count for category
  int getResourceCountForCategory(String category) {
    return _allResources.where((r) => r.category == category).length;
  }
}
