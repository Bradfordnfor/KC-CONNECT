import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/models/alumni_model.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/common/snackbar.dart';
import 'package:kc_connect/features/auth/controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlumniController extends GetxController {
  final _allAlumni = <AlumniModel>[].obs;
  final _filteredAlumni = <AlumniModel>[].obs;
  final _searchQuery = ''.obs;
  final _selectedClassFilter = 'All'.obs;
  final _selectedSchoolFilter = 'All'.obs;
  final _showOnlyAvailable = false.obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final _likedAlumni = <String>[].obs;
  final _alumniLikeCounts = <String, int>{}.obs;

  // alumniId → status: 'pending' | 'accepted' | 'declined' | 'cancelled'
  // Only alumni the current student has interacted with are present.
  final _mentorshipStatuses = <String, String>{}.obs;

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

  Future<void> loadAlumni() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      await Future.wait([
        _fetchAlumni(),
        loadLikedAlumni(),
        _loadMentorshipStatuses(),
      ]);

      _isLoading.value = false;
    } catch (e) {
      _errorMessage.value = 'Failed to load alumni';
      _isLoading.value = false;
    }
  }

  Future<void> _fetchAlumni() async {
    final response = await Supabase.instance.client
        .from('users')
        .select(
          'id, full_name, profile_image_url, graduation_year, '
          'institution, bio, career, vision, '
          'available_for_mentorship, email, max_mentees, '
          'expertise, total_mentorship_given, total_likes',
        )
        .eq('role', 'alumni')
        .eq('status', 'active')
        .order('full_name');

    _allAlumni.value =
        (response as List).map((r) => _fromRow(r as Map<String, dynamic>)).toList();
    await _loadLikeCounts();
    _applyFilters();
  }

  Future<void> loadLikedAlumni() async {
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId == null) return;

      final response = await Supabase.instance.client
          .from('alumni_likes')
          .select('alumni_id')
          .eq('user_id', currentUserId);

      _likedAlumni.value =
          (response as List).map((item) => item['alumni_id'] as String).toList();
    } catch (e) {
      debugPrint('Error loading liked alumni: $e');
    }
  }

  /// Loads ALL mentorship request statuses for the current student so the button
  /// correctly reflects pending / accepted / declined states for every alumni.
  Future<void> _loadMentorshipStatuses() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await Supabase.instance.client
          .from('mentorship_requests')
          .select('mentor_id, status')
          .eq('student_id', userId)
          .inFilter('status', ['pending', 'accepted', 'declined']);

      final statuses = <String, String>{};
      for (final row in response as List) {
        statuses[row['mentor_id'] as String] = row['status'] as String;
      }
      _mentorshipStatuses.value = statuses;
    } catch (e) {
      debugPrint('Error loading mentorship statuses: $e');
    }
  }

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
      debugPrint('Error loading like counts: $e');
    }
  }

  bool isAlumniLiked(String alumniId) => _likedAlumni.contains(alumniId);
  int getAlumniLikeCount(String alumniId) => _alumniLikeCounts[alumniId] ?? 0;

  /// Returns the current request status for the given alumni, or null if
  /// no request has been sent.
  String? mentorshipStatus(String alumniId) => _mentorshipStatuses[alumniId];

  /// Whether the "Request Mentorship" button should be disabled.
  /// Disabled when: pending, accepted, or declined.
  bool isMentorshipButtonDisabled(String alumniId) =>
      _mentorshipStatuses.containsKey(alumniId);

  String mentorshipButtonLabel(String alumniId) {
    switch (_mentorshipStatuses[alumniId]) {
      case 'pending':
        return 'Request Pending';
      case 'accepted':
        return 'Mentorship Active';
      case 'declined':
        return 'Request Declined';
      default:
        return 'Request Mentorship';
    }
  }

  Future<void> toggleLike(String alumniId) async {
    try {
      final isCurrentlyLiked = isAlumniLiked(alumniId);
      final alumni = _allAlumni.firstWhere((a) => a.id == alumniId);

      if (isCurrentlyLiked) {
        await _unlikeAlumni(alumniId);
        _likedAlumni.remove(alumniId);
        _alumniLikeCounts[alumniId] = (_alumniLikeCounts[alumniId] ?? 1) - 1;
        AppSnackbar.info('Removed', 'Removed ${alumni.name} from favorites');
      } else {
        await _likeAlumni(alumniId);
        _likedAlumni.add(alumniId);
        _alumniLikeCounts[alumniId] = (_alumniLikeCounts[alumniId] ?? 0) + 1;
        AppSnackbar.success('Liked', 'Added ${alumni.name} to favorites');
      }

      _alumniLikeCounts.refresh();
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to update favorite status');
    }
  }

  Future<void> _likeAlumni(String alumniId) async {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null) throw Exception('Not authenticated');
    await Supabase.instance.client.from('alumni_likes').insert({
      'user_id': currentUserId,
      'alumni_id': alumniId,
    });
  }

  Future<void> _unlikeAlumni(String alumniId) async {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null) throw Exception('Not authenticated');
    await Supabase.instance.client
        .from('alumni_likes')
        .delete()
        .eq('user_id', currentUserId)
        .eq('alumni_id', alumniId);
  }

  void searchAlumni(String query) {
    _searchQuery.value = query.toLowerCase();
    _applyFilters();
  }

  void filterByClass(String classYear) {
    _selectedClassFilter.value = classYear;
    _applyFilters();
  }

  void filterBySchool(String school) {
    _selectedSchoolFilter.value = school;
    _applyFilters();
  }

  void toggleShowOnlyAvailable() {
    _showOnlyAvailable.value = !_showOnlyAvailable.value;
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = _allAlumni.toList();

    if (_showOnlyAvailable.value) {
      filtered = filtered.where((a) => a.isAvailableForMentorship).toList();
    }

    if (_selectedClassFilter.value != 'All') {
      filtered = filtered
          .where((a) => a.classInfo.contains(_selectedClassFilter.value))
          .toList();
    }

    if (_selectedSchoolFilter.value != 'All') {
      filtered = filtered
          .where((a) => a.school.contains(_selectedSchoolFilter.value))
          .toList();
    }

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

    filtered.sort((a, b) => a.name.compareTo(b.name));
    _filteredAlumni.value = filtered;
  }

  List<String> getAvailableClassYears() {
    final years = _allAlumni
        .map((a) => a.classYear?.toString() ?? '')
        .where((y) => y.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    years.insert(0, 'All');
    return years;
  }

  List<String> getAvailableSchools() {
    final schools = _allAlumni.map((a) => a.school).toSet().toList()..sort();
    schools.insert(0, 'All');
    return schools;
  }

  Future<void> requestMentorship(String alumniId) async {
    try {
      final alumni = _allAlumni.firstWhere((a) => a.id == alumniId);

      if (isMentorshipButtonDisabled(alumniId)) return;

      // Bio check — alumni need this to make an informed decision
      final me = Get.find<AuthController>().currentUser;
      final currentBio = (me?['bio'] as String? ?? '').trim();
      if (currentBio.isEmpty) {
        final filled = await _promptForBio();
        if (!filled) return; // user cancelled
      }

      if (!alumni.isAvailableForMentorship) {
        AppSnackbar.warning(
          'Not Available',
          '${alumni.name} is not currently available for mentorship',
        );
        return;
      }

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        AppSnackbar.error('Not Signed In', 'Please sign in to request mentorship');
        return;
      }

      // Check if this student already has an accepted mentor
      final existingAccepted = await Supabase.instance.client
          .from('mentorship_requests')
          .select('id')
          .eq('student_id', userId)
          .eq('status', 'accepted');

      if ((existingAccepted as List).isNotEmpty) {
        AppSnackbar.warning(
          'Already Has Mentor',
          'You already have an active mentor. You can only have one mentor at a time.',
        );
        return;
      }

      // Capacity check: count active (accepted) mentorships for this alumni
      final activeList = await Supabase.instance.client
          .from('mentorship_requests')
          .select('id')
          .eq('mentor_id', alumniId)
          .eq('status', 'accepted');

      if ((activeList as List).length >= alumni.maxMentees) {
        AppSnackbar.warning(
          'Mentor Full',
          '${alumni.name} has reached their maximum number of mentees.',
        );
        return;
      }

      // Insert the request and get its ID back
      final response = await Supabase.instance.client
          .from('mentorship_requests')
          .insert({
            'student_id': userId,
            'mentor_id': alumniId,
            'status': 'pending',
            'requested_at': DateTime.now().toIso8601String(),
          })
          .select('id')
          .single();

      final requestId = response['id'] as String;

      // Notify the alumni — include student bio for informed decision-making
      final myProfile = Get.find<AuthController>().currentUser;
      final studentName = myProfile?['full_name'] as String? ?? 'A student';
      final studentBio = (myProfile?['bio'] as String? ?? '').trim();

      await Supabase.instance.client.from('notifications').insert({
        'user_id': alumniId,
        'title': 'New Mentorship Request',
        'message': '$studentName would like you to be their mentor.',
        'type': 'mentorship',
        'action_type': 'mentorship_request',
        'action_id': requestId,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
        'metadata': {
          'student_name': studentName,
          if (studentBio.isNotEmpty) 'student_bio': studentBio,
        },
      });

      // Update local state immediately so button disables without a reload
      _mentorshipStatuses[alumniId] = 'pending';
      _mentorshipStatuses.refresh();

      AppSnackbar.success(
        'Request Sent',
        'Your mentorship request has been sent to ${alumni.name}',
      );
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to send mentorship request');
    }
  }

  Future<void> endMentorship(String alumniId) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await Supabase.instance.client
          .from('mentorship_requests')
          .select('id')
          .eq('student_id', userId)
          .eq('mentor_id', alumniId)
          .eq('status', 'accepted')
          .maybeSingle();

      if (response == null) {
        AppSnackbar.error('Error', 'No active mentorship found.');
        return;
      }

      final requestId = response['id'] as String;

      await Supabase.instance.client
          .from('mentorship_requests')
          .update({'status': 'ended'})
          .eq('id', requestId);

      final me = Get.find<AuthController>().currentUser;
      final studentName = me?['full_name'] as String? ?? 'Your mentee';

      await Supabase.instance.client.from('notifications').insert({
        'user_id': alumniId,
        'title': 'Mentorship Ended',
        'message': '$studentName has ended their mentorship with you.',
        'type': 'mentorship',
        'action_type': 'mentorship_ended',
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      _mentorshipStatuses.remove(alumniId);
      _mentorshipStatuses.refresh();

      AppSnackbar.info('Ended', 'Your mentorship has been ended.');
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to end mentorship.');
    }
  }

  /// Shows a dialog asking the student to fill their bio before requesting
  /// mentorship. Returns true when the bio is saved, false if cancelled.
  Future<bool> _promptForBio() async {
    final bioController = TextEditingController();
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(
          'Add Your Bio First',
          style: AppTextStyles.subHeading.copyWith(color: AppColors.blue),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alumni need to know a little about you before accepting a mentorship request. Please write a brief bio.',
              style: AppTextStyles.body.copyWith(
                  color: Colors.grey[700], height: 1.5),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bioController,
              maxLines: 4,
              maxLength: 300,
              decoration: InputDecoration(
                hintText: 'e.g. I am a Grade 10 student passionate about science and engineering...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: AppColors.backgroundColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              final bio = bioController.text.trim();
              if (bio.isEmpty) {
                AppSnackbar.warning('Required', 'Please write a short bio');
                return;
              }
              final userId =
                  Supabase.instance.client.auth.currentUser?.id;
              if (userId == null) {
                Get.back(result: false);
                return;
              }
              await Supabase.instance.client
                  .from('users')
                  .update({'bio': bio})
                  .eq('id', userId);
              // Refresh local user profile so subsequent checks pass
              await Get.find<AuthController>().refreshProfile();
              Get.back(result: true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Save & Continue'),
          ),
        ],
      ),
    );
    bioController.dispose();
    return result ?? false;
  }

  List<AlumniModel> getAlumniByExpertise(String expertise) {
    return _allAlumni
        .where(
          (a) => a.expertise.any(
            (e) => e.toLowerCase().contains(expertise.toLowerCase()),
          ),
        )
        .toList();
  }

  Future<void> refreshAlumni() async {
    await loadAlumni();
  }

  void resetFilters() {
    _searchQuery.value = '';
    _selectedClassFilter.value = 'All';
    _selectedSchoolFilter.value = 'All';
    _showOnlyAvailable.value = false;
    _applyFilters();
  }

  Map<String, int> getStatistics() {
    return {
      'total': _allAlumni.length,
      'available': _allAlumni.where((a) => a.isAvailableForMentorship).length,
      'filtered': _filteredAlumni.length,
      'liked': _likedAlumni.length,
    };
  }

  // ─── Mapper ─────────────────────────────────────────────────────────────────

  AlumniModel _fromRow(Map<String, dynamic> row) {
    final expertise =
        (row['expertise'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final classYear = row['graduation_year'];
    return AlumniModel(
      id: row['id'] ?? '',
      name: row['full_name'] ?? '',
      role: 'Alumni',
      school: row['institution'] ?? 'Knowledge Center',
      classInfo: classYear != null ? 'Class of $classYear' : 'Alumni',
      imageUrl: row['profile_image_url'],
      bio: row['bio'] ?? '',
      career: row['career'] ?? '',
      vision: row['vision'] ?? '',
      isAvailableForMentorship: row['available_for_mentorship'] ?? false,
      email: row['email'],
      linkedin: row['linkedin_url'],
      expertise: expertise,
      menteeCount: row['total_mentorship_given'] ?? 0,
      maxMentees: row['max_mentees'] ?? 3,
    );
  }
}
