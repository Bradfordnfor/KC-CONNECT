// lib/features/home/controllers/home_controller.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/models/alumni_model.dart';
import 'package:kc_connect/core/models/event_model.dart';
import 'package:kc_connect/core/models/resource_model.dart';
import 'package:kc_connect/features/auth/controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeController extends GetxController {
  final _stats = <String, int>{}.obs;
  final _featuredEvents = <EventModel>[].obs;
  final _recentResources = <ResourceModel>[].obs;
  final _featuredAlumni = <AlumniModel>[].obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;

  Map<String, int> get stats => _stats;
  List<EventModel> get featuredEvents => _featuredEvents;
  List<ResourceModel> get recentResources => _recentResources;
  List<AlumniModel> get featuredAlumni => _featuredAlumni;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String get welcomeMessage {
    final user = Get.find<AuthController>().currentUser;
    if (user != null) {
      final firstName = (user['full_name'] as String? ?? '').split(' ').first;
      return '$greeting, $firstName!';
    }
    return '$greeting!';
  }

  String getMotivationalMessage() {
    const messages = [
      'Keep learning and growing!',
      'Knowledge is power!',
      'Stay curious and keep exploring!',
      'Every day is a learning opportunity!',
      'Connect, learn, and inspire!',
      'You\'re doing great!',
    ];
    return messages[DateTime.now().weekday % messages.length];
  }

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    _isLoading.value = true;
    _errorMessage.value = '';
    await Future.wait([
      _loadStatistics().catchError((e) => debugPrint('Stats error: $e')),
      _loadFeaturedEvents().catchError((e) => debugPrint('Events error: $e')),
      _loadRecentResources().catchError((e) => debugPrint('Resources error: $e')),
      _loadFeaturedAlumni().catchError((e) => debugPrint('Alumni error: $e')),
    ]);
    _isLoading.value = false;
  }

  Future<void> _loadStatistics() async {
    final db = Supabase.instance.client;
    final userId = db.auth.currentUser?.id;
    final now = DateTime.now().toIso8601String();

    final results = await Future.wait([
      db.from('events').select('id').neq('status', 'cancelled').neq('status', 'draft'),
      db.from('resources').select('id').eq('status', 'active'),
      db.from('users').select('id').eq('role', 'alumni').eq('status', 'active'),
      if (userId != null)
        db.from('notifications').select('id').eq('user_id', userId).eq('is_read', false)
      else
        Future.value(<dynamic>[]),
      if (userId != null)
        db.from('event_registrations').select('id').eq('user_id', userId).eq('status', 'registered')
      else
        Future.value(<dynamic>[]),
      if (userId != null)
        db.from('user_favorites').select('id').eq('user_id', userId)
      else
        Future.value(<dynamic>[]),
      // Active pinned messages (for staff/alumni card)
      db.from('pinned_messages').select('id').gt('pinned_until', now),
    ]);

    _stats.value = {
      'events': results[0].length,
      'resources': results[1].length,
      'alumni': results[2].length,
      'notifications': results[3].length,
      'myEvents': results[4].length,
      'myResources': results[5].length,
      'pinnedMessages': results[6].length,
    };
  }

  Future<void> _loadFeaturedEvents() async {
    final response = await Supabase.instance.client
        .from('events')
        .select()
        .eq('is_featured', true)
        .eq('status', 'upcoming')
        .gte('start_date', DateTime.now().toIso8601String())
        .order('start_date')
        .limit(3);

    _featuredEvents.value = (response as List).map((e) => _eventFromRow(e)).toList();
  }

  Future<void> _loadRecentResources() async {
    final response = await Supabase.instance.client
        .from('resources')
        .select()
        .eq('status', 'active')
        .order('created_at', ascending: false)
        .limit(5);

    _recentResources.value = (response as List).map((r) => _resourceFromRow(r)).toList();
  }

  Future<void> _loadFeaturedAlumni() async {
    final response = await Supabase.instance.client
        .from('users')
        .select()
        .eq('role', 'alumni')
        .eq('status', 'active')
        .eq('available_for_mentorship', true)
        .limit(3);

    _featuredAlumni.value = (response as List).map((a) => _alumniFromRow(a)).toList();
  }

  Future<void> refreshDashboard() => loadDashboardData();

  int getStat(String key) => _stats[key] ?? 0;

  String getActivitySummary() {
    final myEvents = getStat('myEvents');
    final mySaved = getStat('myResources');
    final unread = getStat('notifications');
    if (myEvents == 0 && mySaved == 0) return 'Start exploring events and resources!';
    final parts = <String>[];
    if (myEvents > 0) parts.add('$myEvents event${myEvents == 1 ? '' : 's'}');
    if (mySaved > 0) parts.add('$mySaved saved resource${mySaved == 1 ? '' : 's'}');
    if (unread > 0) parts.add('$unread new notification${unread == 1 ? '' : 's'}');
    return parts.join(' • ');
  }

  void navigateToEvents() => Get.toNamed('/events');
  void navigateToResources() => Get.toNamed('/resources');
  void navigateToAlumni() => Get.toNamed('/alumni');
  void navigateToNotifications() => Get.toNamed('/news');
  void navigateToProfile() => Get.toNamed('/profile');

  // ─── Mappers ────────────────────────────────────────────────────────────────

  EventModel _eventFromRow(Map<String, dynamic> row) {
    final startDate = DateTime.tryParse(row['start_date'] ?? '') ?? DateTime.now();
    return EventModel(
      id: row['id'] ?? '',
      title: row['title'] ?? '',
      description: row['description'] ?? '',
      type: _capitalise(row['event_type'] ?? 'other'),
      date: startDate,
      time: '${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')}',
      host: row['host_name'],
      location: row['venue'],
      imageUrl: row['banner_image_url'],
      capacity: row['max_capacity'],
      registeredCount: row['current_registrations'] ?? 0,
      isFeatured: row['is_featured'] ?? false,
    );
  }

  ResourceModel _resourceFromRow(Map<String, dynamic> row) {
    return ResourceModel(
      id: row['id'] ?? '',
      title: row['title'] ?? '',
      category: _mapCategory(row['category'] ?? ''),
      subject: row['subject'],
      description: row['description'] ?? '',
      fileUrl: row['file_url'],
      imageUrl: row['thumbnail_url'],
      uploadedBy: row['uploaded_by'] ?? '',
      uploaderName: row['uploader_name'] ?? '',
      uploadedDate: DateTime.tryParse(row['created_at'] ?? '') ?? DateTime.now(),
      downloads: row['download_count'] ?? 0,
    );
  }

  AlumniModel _alumniFromRow(Map<String, dynamic> row) {
    final expertise = (row['expertise'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final classYear = row['graduation_year'];
    return AlumniModel(
      id: row['id'] ?? '',
      name: row['full_name'] ?? '',
      role: row['current_position'] ?? 'Alumni',
      school: row['school'] ?? 'Knowledge College',
      classInfo: classYear != null ? 'Class of $classYear' : 'Alumni',
      imageUrl: row['profile_image_url'],
      bio: row['bio'] ?? '',
      career: [row['current_position'], row['company']].where((v) => v != null && v.toString().isNotEmpty).join(' at '),
      vision: row['bio'] ?? '',
      isAvailableForMentorship: row['available_for_mentorship'] ?? false,
      email: row['email'],
      linkedin: row['linkedin_url'],
      expertise: expertise,
      menteeCount: row['total_mentorship_given'] ?? 0,
    );
  }

  String _capitalise(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _mapCategory(String dbCategory) {
    switch (dbCategory.toLowerCase()) {
      case 'o/l': return 'Ordinary Level';
      case 'a/l': return 'Advanced Level';
      default: return dbCategory.isNotEmpty ? dbCategory : 'Other Books';
    }
  }
}
