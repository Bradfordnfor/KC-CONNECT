import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
import 'package:kc_connect/features/auth/controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ActivityItem {
  final IconData icon;
  final String title;
  final DateTime timestamp;
  final Color color;

  ActivityItem({
    required this.icon,
    required this.title,
    required this.timestamp,
    required this.color,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inDays >= 7) return '${(diff.inDays / 7).floor()} week${(diff.inDays / 7).floor() == 1 ? '' : 's'} ago';
    if (diff.inDays > 0) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    if (diff.inHours > 0) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    return '${diff.inMinutes} min ago';
  }
}

class ProfileController extends GetxController {
  final _myEventsCount = 0.obs;
  final _savedCount = 0.obs;
  final _downloadsCount = 0.obs;
  final _recentActivity = <ActivityItem>[].obs;
  final _isLoading = false.obs;
  final _isUpdating = false.obs;
  final _isUploadingPhoto = false.obs;

  // Rewards
  final _points = 0.obs;
  final _pointsThisMonth = 0.obs;
  final _rewardCheckpoint = 0.obs;
  final _timesRedeemed = 0.obs;

  int get myEventsCount => _myEventsCount.value;
  int get savedCount => _savedCount.value;
  int get downloadsCount => _downloadsCount.value;
  List<ActivityItem> get recentActivity => _recentActivity;
  bool get isLoading => _isLoading.value;
  bool get isUpdating => _isUpdating.value;
  bool get isUploadingPhoto => _isUploadingPhoto.value;

  int get points => _points.value;
  int get pointsThisMonth => _pointsThisMonth.value;
  int get timesRedeemed => _timesRedeemed.value;
  /// Points earned since the last reward claim
  int get netPoints => (_points.value - _rewardCheckpoint.value).clamp(0, 99999);
  /// Whether the user has an unused free-event registration waiting
  bool get hasRewardClaim => netPoints >= 50;
  /// Points still needed to unlock the next free event (0 when claim is ready)
  int get pointsToNextClaim => hasRewardClaim ? 0 : 50 - netPoints;

  Map<String, dynamic>? get user => Get.find<AuthController>().currentUser;

  String get name => user?['full_name'] as String? ?? '';
  String get email => user?['email'] as String? ?? '';
  String get phone => user?['phone_number'] as String? ?? '';
  String get bio => user?['bio'] as String? ?? '';
  String get role => _formatRole(user?['role'] as String? ?? '');
  String get institution => user?['institution'] as String? ?? 'Knowledge Center';
  String get level => _formatLevel(user?['level'] as String? ?? '');
  String get classYear {
    final cy = user?['class_year'];
    return cy != null ? 'Class of $cy' : '';
  }
  String? get imageUrl => user?['profile_image_url'] as String?;

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  Future<void> loadStats() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    _isLoading.value = true;
    try {
      final results = await Future.wait([
        Supabase.instance.client
            .from('event_registrations')
            .select('id')
            .eq('user_id', userId)
            .eq('status', 'registered'),
        Supabase.instance.client
            .from('user_favorites')
            .select('id')
            .eq('user_id', userId),
        Supabase.instance.client
            .from('downloads')
            .select('id')
            .eq('user_id', userId),
      ]);

      _myEventsCount.value = (results[0] as List).length;
      _savedCount.value = (results[1] as List).length;
      _downloadsCount.value = (results[2] as List).length;

      // Load reward points separately so a missing column doesn't block the rest
      try {
        final row = await Supabase.instance.client
            .from('users')
            .select('points, points_this_month, reward_checkpoint, times_redeemed')
            .eq('id', userId)
            .single();
        _points.value          = row['points']            as int? ?? 0;
        _pointsThisMonth.value = row['points_this_month'] as int? ?? 0;
        _rewardCheckpoint.value= row['reward_checkpoint'] as int? ?? 0;
        _timesRedeemed.value   = row['times_redeemed']    as int? ?? 0;
      } catch (e) {
        debugPrint('Rewards points load error: $e');
      }

      await _loadRecentActivity(userId);
    } catch (e) {
      debugPrint('Error loading profile stats: $e');
    }
    _isLoading.value = false;
  }

  Future<void> _loadRecentActivity(String userId) async {
    try {
      final results = await Future.wait([
        Supabase.instance.client
            .from('downloads')
            .select('created_at, resources(title)')
            .eq('user_id', userId)
            .order('created_at', ascending: false)
            .limit(3),
        Supabase.instance.client
            .from('event_registrations')
            .select('created_at, events(title)')
            .eq('user_id', userId)
            .order('created_at', ascending: false)
            .limit(3),
        Supabase.instance.client
            .from('user_favorites')
            .select('created_at, resources(title)')
            .eq('user_id', userId)
            .order('created_at', ascending: false)
            .limit(3),
      ]);

      final activities = <ActivityItem>[];

      for (final d in results[0] as List) {
        final title = d['resources']?['title'] as String? ?? 'a resource';
        activities.add(ActivityItem(
          icon: Icons.download,
          title: 'Downloaded $title',
          timestamp: DateTime.tryParse(d['created_at'] ?? '') ?? DateTime.now(),
          color: AppColors.deepRed,
        ));
      }

      for (final e in results[1] as List) {
        final title = e['events']?['title'] as String? ?? 'an event';
        activities.add(ActivityItem(
          icon: Icons.event,
          title: 'Registered for $title',
          timestamp: DateTime.tryParse(e['created_at'] ?? '') ?? DateTime.now(),
          color: AppColors.blue,
        ));
      }

      for (final f in results[2] as List) {
        final title = f['resources']?['title'] as String? ?? 'a resource';
        activities.add(ActivityItem(
          icon: Icons.bookmark,
          title: 'Saved $title',
          timestamp: DateTime.tryParse(f['created_at'] ?? '') ?? DateTime.now(),
          color: AppColors.blue,
        ));
      }

      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _recentActivity.value = activities.take(5).toList();
    } catch (e) {
      debugPrint('Error loading recent activity: $e');
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String phone,
    String? bio,
    String? level,
  }) async {
    try {
      _isUpdating.value = true;
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('Not authenticated');

      await Supabase.instance.client.from('users').update({
        'full_name': fullName.trim(),
        'phone_number': phone.trim(),
        if (bio != null) 'bio': bio.trim(),
        if (level != null && level.isNotEmpty) 'level': level,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      await Get.find<AuthController>().refreshProfile();
      AppSnackbar.success('Updated', 'Profile updated successfully');
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to update profile');
    } finally {
      _isUpdating.value = false;
    }
  }

  Future<void> uploadProfilePicture() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
    );
    if (picked == null) return;

    _isUploadingPhoto.value = true;
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('Not authenticated');

      final bytes = await picked.readAsBytes();
      final ext = picked.name.split('.').last.toLowerCase();
      final storagePath = '$userId/avatar.$ext';

      await Supabase.instance.client.storage
          .from('profile_pictures')
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final imageUrl = Supabase.instance.client.storage
          .from('profile_pictures')
          .getPublicUrl(storagePath);

      await Supabase.instance.client
          .from('users')
          .update({'profile_image_url': imageUrl}).eq('id', userId);

      await Get.find<AuthController>().refreshProfile();
      AppSnackbar.success('Updated', 'Profile picture updated');
    } catch (e) {
      debugPrint('Upload profile picture error: $e');
      AppSnackbar.error('Error', 'Failed to upload picture');
    } finally {
      _isUploadingPhoto.value = false;
    }
  }

  Future<void> refreshProfile() async {
    await Get.find<AuthController>().refreshProfile();
    await loadStats();
  }

  String _formatRole(String role) =>
      role.isEmpty ? '' : role[0].toUpperCase() + role.substring(1);

  String _formatLevel(String level) {
    switch (level.toLowerCase()) {
      case 'o/l': return 'Ordinary Level';
      case 'a/l': return 'Advanced Level';
      case 'graduated': return 'Graduated';
      default: return level;
    }
  }
}
