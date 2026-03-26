import 'package:get/get.dart';
import 'package:kc_connect/core/models/alumni_model.dart';
import 'package:kc_connect/core/widgets/common/snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlumniController extends GetxController {
  // Reactive state
  final _allAlumni = <AlumniModel>[].obs;
  final _filteredAlumni = <AlumniModel>[].obs;
  final _searchQuery = ''.obs;
  final _selectedClassFilter = 'All'.obs;
  final _selectedSchoolFilter = 'All'.obs;
  final _showOnlyAvailable = false.obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final _mentorshipRequests =
      <String>[].obs; // Alumni IDs with pending requests
  final _likedAlumni = <String>[].obs; // Alumni IDs that current user liked
  final _alumniLikeCounts = <String, int>{}.obs; // Alumni ID -> like count

  // Getters
  List<AlumniModel> get allAlumni => _allAlumni;
  List<AlumniModel> get filteredAlumni => _filteredAlumni;
  String get searchQuery => _searchQuery.value;
  String get selectedClassFilter => _selectedClassFilter.value;
  String get selectedSchoolFilter => _selectedSchoolFilter.value;
  bool get showOnlyAvailable => _showOnlyAvailable.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    loadAlumni();
    loadLikedAlumni();
  }

  // Load alumni
  Future<void> loadAlumni() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Load mock data (replace with Supabase later)
      _allAlumni.value = AlumniModel.mockList();
      _applyFilters();

      // Load like counts for each alumni
      await _loadLikeCounts();

      _isLoading.value = false;
    } catch (e) {
      _errorMessage.value = 'Failed to load alumni: ${e.toString()}';
      _isLoading.value = false;
    }
  }

  // Load alumni that current user has liked
  Future<void> loadLikedAlumni() async {
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId == null) return;

      final response = await Supabase.instance.client
          .from('alumni_likes')
          .select('alumni_id')
          .eq('user_id', currentUserId);

      _likedAlumni.value = (response as List)
          .map((item) => item['alumni_id'] as String)
          .toList();
    } catch (e) {
      print('Error loading liked alumni: $e');
    }
  }

  // Load like counts for all alumni
  Future<void> _loadLikeCounts() async {
    try {
      final alumniIds = _allAlumni.map((a) => a.id).toList();
      if (alumniIds.isEmpty) {
        _alumniLikeCounts.value = {};
        return;
      }
      final response = await Supabase.instance.client
          .from('users')
          .select('id, total_likes')
          .inFilter('id', alumniIds);

      final counts = <String, int>{};
      for (final row in response as List) {
        counts[row['id']] = row['total_likes'] ?? 0;
      }
      _alumniLikeCounts.value = counts;
    } catch (e) {
      print('Error loading like counts: $e');
    }
  }

  // Check if current user liked an alumni
  bool isAlumniLiked(String alumniId) {
    return _likedAlumni.contains(alumniId);
  }

  // Get like count for an alumni
  int getAlumniLikeCount(String alumniId) {
    return _alumniLikeCounts[alumniId] ?? 0;
  }

  // Toggle like/unlike
  Future<void> toggleLike(String alumniId) async {
    try {
      final isCurrentlyLiked = isAlumniLiked(alumniId);
      final alumni = _allAlumni.firstWhere((a) => a.id == alumniId);

      if (isCurrentlyLiked) {
        // Unlike
        await _unlikeAlumni(alumniId);
        _likedAlumni.remove(alumniId);
        _alumniLikeCounts[alumniId] = (_alumniLikeCounts[alumniId] ?? 1) - 1;

        AppSnackbar.info('Removed', 'Removed ${alumni.name} from favorites');
      } else {
        // Like
        await _likeAlumni(alumniId);
        _likedAlumni.add(alumniId);
        _alumniLikeCounts[alumniId] = (_alumniLikeCounts[alumniId] ?? 0) + 1;

        AppSnackbar.success('Liked', 'Added ${alumni.name} to favorites');
      }

      // Trigger UI update
      _alumniLikeCounts.refresh();
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to update favorite status');
    }
  }

  // Like alumni (Supabase)
  Future<void> _likeAlumni(String alumniId) async {
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId == null) throw Exception('Not authenticated');

      await Supabase.instance.client.from('alumni_likes').insert({
        'user_id': currentUserId,
        'alumni_id': alumniId,
      });
    } catch (e) {
      throw Exception('Failed to like alumni: $e');
    }
  }

  // Unlike alumni (Supabase)
  Future<void> _unlikeAlumni(String alumniId) async {
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId == null) throw Exception('Not authenticated');

      await Supabase.instance.client
          .from('alumni_likes')
          .delete()
          .eq('user_id', currentUserId)
          .eq('alumni_id', alumniId);
    } catch (e) {
      throw Exception('Failed to unlike alumni: $e');
    }
  }

  // Search alumni
  void searchAlumni(String query) {
    _searchQuery.value = query.toLowerCase();
    _applyFilters();
  }

  // Filter by class year
  void filterByClass(String classYear) {
    _selectedClassFilter.value = classYear;
    _applyFilters();
  }

  // Filter by school
  void filterBySchool(String school) {
    _selectedSchoolFilter.value = school;
    _applyFilters();
  }

  // Toggle show only available for mentorship
  void toggleShowOnlyAvailable() {
    _showOnlyAvailable.value = !_showOnlyAvailable.value;
    _applyFilters();
  }

  // Apply all filters
  void _applyFilters() {
    var filtered = _allAlumni.toList();

    // Filter by availability for mentorship
    if (_showOnlyAvailable.value) {
      filtered = filtered.where((a) => a.isAvailableForMentorship).toList();
    }

    // Filter by class year
    if (_selectedClassFilter.value != 'All') {
      filtered = filtered
          .where((a) => a.classInfo.contains(_selectedClassFilter.value))
          .toList();
    }

    // Filter by school
    if (_selectedSchoolFilter.value != 'All') {
      filtered = filtered
          .where((a) => a.school.contains(_selectedSchoolFilter.value))
          .toList();
    }

    // Filter by search query
    if (_searchQuery.value.isNotEmpty) {
      filtered = filtered.where((a) {
        return a.name.toLowerCase().contains(_searchQuery.value) ||
            a.role.toLowerCase().contains(_searchQuery.value) ||
            a.school.toLowerCase().contains(_searchQuery.value) ||
            a.classInfo.toLowerCase().contains(_searchQuery.value) ||
            a.bio.toLowerCase().contains(_searchQuery.value) ||
            a.expertise.any(
              (e) => e.toLowerCase().contains(_searchQuery.value),
            );
      }).toList();
    }

    // Sort by name
    filtered.sort((a, b) => a.name.compareTo(b.name));

    _filteredAlumni.value = filtered;
  }

  // Get available class years
  List<String> getAvailableClassYears() {
    final years =
        _allAlumni
            .map((a) => a.classYear?.toString() ?? '')
            .where((y) => y.isNotEmpty)
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a)); // Most recent first
    years.insert(0, 'All');
    return years;
  }

  // Get available schools
  List<String> getAvailableSchools() {
    final schools = _allAlumni.map((a) => a.school).toSet().toList()..sort();
    schools.insert(0, 'All');
    return schools;
  }

  // Request mentorship
  Future<void> requestMentorship(String alumniId) async {
    try {
      final alumni = _allAlumni.firstWhere((a) => a.id == alumniId);

      // Check if already requested
      if (_mentorshipRequests.contains(alumniId)) {
        AppSnackbar.info(
          'Already Requested',
          'You have already sent a mentorship request to ${alumni.name}',
        );
        return;
      }

      // Check if available
      if (!alumni.isAvailableForMentorship) {
        AppSnackbar.warning(
          'Not Available',
          '${alumni.name} is not currently available for mentorship',
        );
        return;
      }

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Add to requests
      _mentorshipRequests.add(alumniId);

      AppSnackbar.success(
        'Request Sent',
        'Your mentorship request has been sent to ${alumni.name}',
      );
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to send mentorship request');
    }
  }

  // Cancel mentorship request
  Future<void> cancelMentorshipRequest(String alumniId) async {
    try {
      final alumni = _allAlumni.firstWhere((a) => a.id == alumniId);

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Remove from requests
      _mentorshipRequests.remove(alumniId);

      AppSnackbar.info(
        'Request Cancelled',
        'Your mentorship request to ${alumni.name} has been cancelled',
      );
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to cancel mentorship request');
    }
  }

  // Check if mentorship request sent
  bool hasMentorshipRequest(String alumniId) {
    return _mentorshipRequests.contains(alumniId);
  }

  // Get alumni by expertise
  List<AlumniModel> getAlumniByExpertise(String expertise) {
    return _allAlumni
        .where(
          (a) => a.expertise.any(
            (e) => e.toLowerCase().contains(expertise.toLowerCase()),
          ),
        )
        .toList();
  }

  // Refresh alumni
  Future<void> refreshAlumni() async {
    await loadAlumni();
    await loadLikedAlumni();
  }

  // Reset filters
  void resetFilters() {
    _searchQuery.value = '';
    _selectedClassFilter.value = 'All';
    _selectedSchoolFilter.value = 'All';
    _showOnlyAvailable.value = false;
    _applyFilters();
  }

  // Get alumni count statistics
  Map<String, int> getStatistics() {
    return {
      'total': _allAlumni.length,
      'available': _allAlumni.where((a) => a.isAvailableForMentorship).length,
      'filtered': _filteredAlumni.length,
      'liked': _likedAlumni.length,
    };
  }
}
