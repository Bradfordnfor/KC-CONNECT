// lib/features/resources/controllers/resources_controller.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/models/resource_model.dart';
import 'package:kc_connect/features/home/controllers/home_controller.dart';
import 'package:kc_connect/core/screens/in_app_image_viewer.dart';
import 'package:kc_connect/core/screens/in_app_pdf_viewer.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final _downloadedResources = <String, String>{}.obs; // id → local file path
  final _downloadingResourceIds = <String>[].obs;

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
  String? get currentUserId => Supabase.instance.client.auth.currentUser?.id;

  bool isDownloaded(String id) => _downloadedResources.containsKey(id);
  bool isDownloading(String id) => _downloadingResourceIds.contains(id);

  @override
  void onInit() {
    super.onInit();
    _loadCachedResourceList(); // show instantly from cache
    loadResources();            // then refresh from network
    loadFavorites();
    _loadDownloadedResources();

    // Re-load per-user data when a different user signs in so state never leaks.
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      if (event.event == AuthChangeEvent.signedIn) {
        loadFavorites();
        _loadDownloadedResources();
      } else if (event.event == AuthChangeEvent.signedOut) {
        _favoriteResources.value = [];
        _downloadedResources.value = {};
        _applyFilters();
      }
    });
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
      _saveResourceListCache(response);
    } catch (e) {
      // Keep cached data visible; only show error if there's nothing to show
      if (_allResources.isEmpty) {
        _errorMessage.value = 'No internet connection. Pull to refresh when online.';
      }
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadCachedResourceList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('resources_list_cache');
      if (raw == null) return;
      final list = jsonDecode(raw) as List;
      if (_allResources.isEmpty) {
        _allResources.value = list.map(_fromRow).toList();
        _applyFilters();
      }
    } catch (e) {
      debugPrint('Load resource cache error: $e');
    }
  }

  Future<void> _saveResourceListCache(List rows) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('resources_list_cache', jsonEncode(rows));
    } catch (e) {
      debugPrint('Save resource cache error: $e');
    }
  }

  Future<void> loadFavorites() async {
    try {
      final uid = currentUserId;
      if (uid == null) return;

      final response = await Supabase.instance.client
          .from('user_favorites')
          .select('resource_id')
          .eq('user_id', uid);

      _favoriteResources.value =
          (response as List).map((item) => item['resource_id'] as String).toList();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  String get _downloadedKey =>
      'downloaded_resources_${currentUserId ?? 'local'}';

  Future<void> _loadDownloadedResources() async {
    try {
      _downloadedResources.value = {};
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_downloadedKey);
      if (json == null) return;
      final raw = Map<String, String>.from(jsonDecode(json) as Map);
      // Verify files still exist on disk
      final valid = <String, String>{};
      for (final entry in raw.entries) {
        if (await File(entry.value).exists()) {
          valid[entry.key] = entry.value;
        }
      }
      _downloadedResources.value = valid;
    } catch (e) {
      debugPrint('Load downloaded resources error: $e');
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
      // Keep home page activity stats in sync
      _refreshHomeStats();
    } catch (e) {
      debugPrint('Toggle favorite error: $e');
      AppSnackbar.error('Error', 'Failed to update favourite');
    }
  }

  void _refreshHomeStats() {
    try {
      Get.find<HomeController>().loadDashboardData();
    } catch (_) {
      // HomeController not yet registered (user hasn't visited home tab) — ignore.
    }
  }

  Future<void> _addFavorite(String resourceId) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');
    await Supabase.instance.client
        .from('user_favorites')
        .insert({'user_id': uid, 'resource_id': resourceId});
  }

  Future<void> _removeFavorite(String resourceId) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');
    await Supabase.instance.client
        .from('user_favorites')
        .delete()
        .eq('user_id', uid)
        .eq('resource_id', resourceId);
  }

  // ─── Open (tap on card) ─────────────────────────────────────────────────────
  // Mirrors _openChatFile in learn_page.dart: in-app viewers only, no external apps.

  Future<void> openResource(ResourceModel resource) async {
    if (resource.fileUrl == null || resource.fileUrl!.isEmpty) {
      AppSnackbar.error('Unavailable', 'No file available for this resource');
      return;
    }

    // Use the stored file_type column (e.g. 'pdf', 'docx', 'jpg').
    // Fall back to parsing the URL only for old records missing file_type.
    final ext = (resource.fileType?.isNotEmpty == true
            ? resource.fileType!
            : (Uri.tryParse(resource.fileUrl!)?.pathSegments.last ?? resource.fileUrl!)
                .split('.')
                .last)
        .toLowerCase();
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext);
    final isPdf = ext == 'pdf';

    // 1. Offline copy — serve from local file, no network needed.
    if (_downloadedResources.containsKey(resource.id)) {
      final localPath = _downloadedResources[resource.id]!;
      final file = File(localPath);
      if (await file.exists()) {
        if (isImage) {
          final bytes = await file.readAsBytes();
          Get.to(() => InAppImageViewer(bytes: bytes, title: resource.title));
        } else if (isPdf) {
          Get.to(() => InAppPdfViewer(localPath: localPath, title: resource.title));
        } else {
          AppSnackbar.info('Cannot Open', 'This file type can only be saved offline, not viewed in-app.');
        }
        return;
      } else {
        _downloadedResources.remove(resource.id);
        _persistDownloadedMap();
      }
    }

    // 2. Network — build the public URL and pass to the in-app viewer.
    //    Same pattern as chat: public URL → InAppImageViewer / InAppPdfViewer.
    try {
      final publicUrl = resource.fileUrl!.startsWith('http')
          ? resource.fileUrl!
          : Supabase.instance.client.storage
              .from('resources')
              .getPublicUrl(_extractStoragePath(resource.fileUrl!));

      if (isImage) {
        Get.to(() => InAppImageViewer(imageUrl: publicUrl, title: resource.title));
      } else if (isPdf) {
        Get.to(() => InAppPdfViewer(url: publicUrl, title: resource.title));
      } else {
        // DOC/DOCX — no in-app viewer exists. Show same message as chat.
        AppSnackbar.info('Cannot Open', 'This file type cannot be viewed in-app. Use the download button to save it.');
        return;
      }

      _trackDownload(resource);
    } catch (e) {
      debugPrint('Open resource error: $e');
      AppSnackbar.error('Error', 'Failed to open resource');
    }
  }

  void _trackDownload(ResourceModel resource) async {
    try {
      final uid = currentUserId;
      if (uid == null) return;
      await Future.wait([
        Supabase.instance.client
            .from('resources')
            .update({'download_count': resource.downloads + 1})
            .eq('id', resource.id),
      ]);
      final index = _allResources.indexWhere((r) => r.id == resource.id);
      if (index != -1) {
        _allResources[index] = resource.copyWith(downloads: resource.downloads + 1);
      }
    } catch (e) {
      debugPrint('Track download error: $e');
    }
  }

  // ─── Save for offline ───────────────────────────────────────────────────────

  Future<void> saveForOffline(ResourceModel resource) async {
    if (resource.fileUrl == null || resource.fileUrl!.isEmpty) {
      AppSnackbar.error('Unavailable', 'No file to download');
      return;
    }
    if (_downloadingResourceIds.contains(resource.id)) return;
    if (_downloadedResources.containsKey(resource.id)) {
      AppSnackbar.info('Already Saved', '${resource.title} is already available offline');
      return;
    }

    _downloadingResourceIds.add(resource.id);

    try {
      final path = _extractStoragePath(resource.fileUrl!);
      final bytes = await Supabase.instance.client.storage
          .from('resources')
          .download(path);

      final dir = await getApplicationDocumentsDirectory();
      final ext = path.contains('.') ? path.split('.').last : 'bin';
      final localFile = File('${dir.path}/res_${resource.id}.$ext');
      await localFile.writeAsBytes(bytes);

      _downloadedResources[resource.id] = localFile.path;
      _downloadedResources.refresh();
      await _persistDownloadedMap();

      AppSnackbar.success('Saved Offline', '${resource.title} is now available offline');
    } catch (e) {
      debugPrint('Save offline error: $e');
      AppSnackbar.error('Error', 'Failed to save resource offline');
    } finally {
      _downloadingResourceIds.remove(resource.id);
    }
  }

  Future<void> _persistDownloadedMap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _downloadedKey,
        jsonEncode(Map<String, String>.from(_downloadedResources)),
      );
    } catch (e) {
      debugPrint('Persist downloaded map error: $e');
    }
  }

  // ─── Delete ─────────────────────────────────────────────────────────────────

  Future<void> deleteResource(ResourceModel resource) async {
    final uid = currentUserId;
    if (uid == null || resource.uploadedBy != uid) {
      AppSnackbar.error('Unauthorized', 'You can only delete your own resources');
      return;
    }

    try {
      // Remove from storage
      if (resource.fileUrl != null && resource.fileUrl!.isNotEmpty) {
        final path = _extractStoragePath(resource.fileUrl!);
        await Supabase.instance.client.storage.from('resources').remove([path]);
      }

      // Remove from DB
      await Supabase.instance.client
          .from('resources')
          .delete()
          .eq('id', resource.id);

      // Clean up local offline copy if present
      if (_downloadedResources.containsKey(resource.id)) {
        final localPath = _downloadedResources[resource.id]!;
        final file = File(localPath);
        if (await file.exists()) await file.delete();
        _downloadedResources.remove(resource.id);
        await _persistDownloadedMap();
      }

      // Remove from favorites list
      _favoriteResources.remove(resource.id);

      // Remove from in-memory list
      _allResources.removeWhere((r) => r.id == resource.id);
      _applyFilters();

      AppSnackbar.success('Deleted', '${resource.title} has been deleted');
    } catch (e) {
      debugPrint('Delete resource error: $e');
      AppSnackbar.error('Error', 'Failed to delete resource');
    }
  }

  // ─── Filters / tabs ─────────────────────────────────────────────────────────

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

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  /// Extracts the storage object path from either a full Supabase URL or a plain path.
  String _extractStoragePath(String fileUrl) {
    const marker = '/resources/';
    final idx = fileUrl.indexOf(marker);
    if (idx != -1 && fileUrl.startsWith('http')) {
      return fileUrl.substring(idx + marker.length);
    }
    return fileUrl;
  }

  // ─── Mapper ──────────────────────────────────────────────────────────────────

  ResourceModel _fromRow(dynamic row) {
    final r = row as Map<String, dynamic>;
    return ResourceModel(
      id: r['id'] ?? '',
      title: r['title'] ?? '',
      category: _mapCategory(r['category'] ?? ''),
      subject: r['subject'],
      description: r['description'] ?? '',
      fileUrl: r['file_url'],
      fileType: r['file_type'] as String?,
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
      case 'other books': return 'Other Books';
      default: return 'Other Books';
    }
  }
}
