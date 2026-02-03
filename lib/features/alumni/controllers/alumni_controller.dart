// lib/features/alumni/controllers/alumni_controller.dart
import 'package:get/get.dart';
import 'package:kc_connect/core/models/alumni_model.dart';

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

      _isLoading.value = false;
    } catch (e) {
      _errorMessage.value = 'Failed to load alumni: ${e.toString()}';
      _isLoading.value = false;
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
        Get.snackbar(
          'Already Requested',
          'You have already sent a mentorship request to ${alumni.name}',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      // Check if available
      if (!alumni.isAvailableForMentorship) {
        Get.snackbar(
          'Not Available',
          '${alumni.name} is not currently available for mentorship',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Add to requests
      _mentorshipRequests.add(alumniId);

      Get.snackbar(
        'Request Sent',
        'Your mentorship request has been sent to ${alumni.name}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send mentorship request',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
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

      Get.snackbar(
        'Request Cancelled',
        'Your mentorship request to ${alumni.name} has been cancelled',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel mentorship request',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
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
    };
  }
}
