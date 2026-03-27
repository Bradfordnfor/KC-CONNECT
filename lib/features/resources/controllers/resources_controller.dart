// lib/features/resources/controllers/resources_controller.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/models/resource_model.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourcesController extends GetxController {
  final _allResources = <ResourceModel>[].obs;
  final _filteredResources = <ResourceModel>[].obs;
  final _currentTabIndex = 0.obs;
  final _searchQuery = ''.obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final _selectedSubject = 'All'.obs;
  final _showFavoritesOnly = false.obs;
  final _favoriteResources = <String>[].obs;

  final List<String> categories = [
    'Ordinary Level',
    'Advanced Level',
    'Other Books',
  ];

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

  Future<void> loadResources() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await Supabase.instance.client
          .from('resources')
          .select()
          .eq('status', 'active')
          .order('created_at', ascending: false);

      _allResources.value = (response as List).map(_fromRow).toList();
      _applyFilters();
      _isLoading.value = false;
    } catch (e) {
      _errorMessage.value = 'Failed to load resources';
      _isLoading.value = false;
    }
  }

  Future<void> loadFavorites() async {
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId == null) return;

      final response = await Supabase.instance.client
          .from('user_favorites')
          .select('resource_id')
          .eq('user_id', currentUserId);

      _favoriteResources.value =
          (response as List).map((item) => item['resource_id'] as String).toList();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  bool isFavorited(String resourceId) => _favoriteResources.contains(resourceId);

  Future<void> toggleFavorite(String resourceId) async {
    try {
      final resource = _allResources.firstWhere((r) => r.id == resourceId);
      if (isFavorited(resourceId)) {
        await _removeFavorite(resourceId);
        _favoriteResources.remove(resourceId);
        AppSnackbar.info('Removed', 'Removed ${resource.title} from favorites');
      } else {
        await _addFavorite(resourceId);
        _favoriteResources.add(resourceId);
        AppSnackbar.success('Saved', 'Added ${resource.title} to favorites');
      }
      _applyFilters();
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to update favourite');
    }
  }

  Future<void> _addFavorite(String resourceId) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');
    await Supabase.instance.client
        .from('user_favorites')
        .insert({'user_id': userId, 'resource_id': resourceId});
  }

  Future<void> _removeFavorite(String resourceId) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');
    await Supabase.instance.client
        .from('user_favorites')
        .delete()
        .eq('user_id', userId)
        .eq('resource_id', resourceId);
  }

  void toggleShowFavoritesOnly() {
    _showFavoritesOnly.value = !_showFavoritesOnly.value;
    _applyFilters();
  }

  void changeTab(int index) {
    if (index != _currentTabIndex.value) {
      _currentTabIndex.value = index;
      _searchQuery.value = '';
      _selectedSubject.value = 'All';
      _showFavoritesOnly.value = false;
      _applyFilters();
    }
  }

  void searchResources(String query) {
    _searchQuery.value = query.toLowerCase();
    _applyFilters();
  }

  void filterBySubject(String subject) {
    _selectedSubject.value = subject;
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = _allResources.toList();
    filtered = filtered.where((r) => r.category == currentCategory).toList();
    if (_showFavoritesOnly.value) {
      filtered = filtered.where((r) => isFavorited(r.id)).toList();
    }
    if (_selectedSubject.value != 'All') {
      filtered = filtered.where((r) => r.subject == _selectedSubject.value).toList();
    }
    if (_searchQuery.value.isNotEmpty) {
      filtered = filtered.where((r) {
        return r.title.toLowerCase().contains(_searchQuery.value) ||
            r.description.toLowerCase().contains(_searchQuery.value) ||
            (r.subject?.toLowerCase().contains(_searchQuery.value) ?? false);
      }).toList();
    }
    _filteredResources.value = filtered;
  }

  List<String> getAvailableSubjects() {
    final subjects = _allResources
        .where((r) => r.category == currentCategory && r.subject != null)
        .map((r) => r.subject!)
        .toSet()
        .toList();
    subjects.insert(0, 'All');
    return subjects;
  }

  Future<void> downloadResource(ResourceModel resource) async {
    if (resource.fileUrl == null || resource.fileUrl!.isEmpty) {
      AppSnackbar.error('Unavailable', 'No file available for this resource');
      return;
    }
    try {
      AppSnackbar.info('Opening', 'Opening ${resource.title}...');
      final uri = Uri.parse(resource.fileUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        // Track the download in DB
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId != null) {
          await Future.wait([
            Supabase.instance.client.from('downloads').insert({
              'user_id': userId,
              'resource_id': resource.id,
            }),
            Supabase.instance.client
                .from('resources')
                .update({'download_count': resource.downloads + 1})
                .eq('id', resource.id),
          ]);
          // Update local state
          final index = _allResources.indexWhere((r) => r.id == resource.id);
          if (index != -1) {
            _allResources[index] = resource.copyWith(downloads: resource.downloads + 1);
          }
        }
      } else {
        AppSnackbar.error('Error', 'Could not open the file');
      }
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to open resource');
    }
  }

  Future<void> refreshResources() async {
    await loadResources();
    await loadFavorites();
  }

  void resetFilters() {
    _searchQuery.value = '';
    _selectedSubject.value = 'All';
    _showFavoritesOnly.value = false;
    _applyFilters();
  }

  int getResourceCountForCategory(String category) =>
      _allResources.where((r) => r.category == category).length;

  int getFavoritesCount() => _favoriteResources.length;

  // ─── Mapper ─────────────────────────────────────────────────────────────────

  ResourceModel _fromRow(dynamic row) {
    final r = row as Map<String, dynamic>;
    return ResourceModel(
      id: r['id'] ?? '',
      title: r['title'] ?? '',
      category: _mapCategory(r['category'] ?? ''),
      subject: r['subject'],
      description: r['description'] ?? '',
      fileUrl: r['file_url'],
      imageUrl: r['thumbnail_url'],
      uploadedBy: r['uploaded_by'] ?? '',
      uploaderName: r['uploader_name'] ?? '',
      uploadedDate: DateTime.tryParse(r['created_at'] ?? '') ?? DateTime.now(),
      downloads: r['download_count'] ?? 0,
    );
  }

  String _mapCategory(String db) {
    switch (db.toLowerCase()) {
      case 'o/l': return 'Ordinary Level';
      case 'a/l': return 'Advanced Level';
      default: return db.isNotEmpty ? db : 'Other Books';
    }
  }
}
