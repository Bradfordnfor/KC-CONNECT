// lib/features/home/controllers/home_controller.dart
import 'package:get/get.dart';
import 'package:kc_connect/core/models/user_model.dart';
import 'package:kc_connect/core/models/resource_model.dart';
import 'package:kc_connect/core/models/event_model.dart';
import 'package:kc_connect/core/models/alumni_model.dart';
import 'package:kc_connect/core/models/notification_model.dart';

class HomeController extends GetxController {
  // Reactive state
  final _currentUser = Rxn<UserModel>();
  final _stats = <String, int>{}.obs;
  final _featuredEvents = <EventModel>[].obs;
  final _recentResources = <ResourceModel>[].obs;
  final _featuredAlumni = <AlumniModel>[].obs;
  final _recentNotifications = <NotificationModel>[].obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;

  // Getters
  UserModel? get currentUser => _currentUser.value;
  Map<String, int> get stats => _stats;
  List<EventModel> get featuredEvents => _featuredEvents;
  List<ResourceModel> get recentResources => _recentResources;
  List<AlumniModel> get featuredAlumni => _featuredAlumni;
  List<NotificationModel> get recentNotifications => _recentNotifications;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  // Greeting based on time of day
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  // Welcome message
  String get welcomeMessage {
    if (currentUser != null) {
      return '$greeting, ${currentUser!.name.split(' ')[0]}!';
    }
    return '$greeting!';
  }

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  // Load all dashboard data
  Future<void> loadDashboardData() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Load current user (mock)
      _currentUser.value = UserModel.mock();

      // Load statistics
      await _loadStatistics();

      // Load featured content
      await _loadFeaturedContent();

      _isLoading.value = false;
    } catch (e) {
      _errorMessage.value = 'Failed to load dashboard: ${e.toString()}';
      _isLoading.value = false;
    }
  }

  // Load statistics
  Future<void> _loadStatistics() async {
    // Get counts from mock data
    final allEvents = EventModel.mockList();
    final allResources = ResourceModel.mockList();
    final allAlumni = AlumniModel.mockList();
    final allNotifications = NotificationModel.mockList();

    _stats.value = {
      'events': allEvents.where((e) => !e.isPast).length,
      'resources': allResources.length,
      'alumni': allAlumni.length,
      'notifications': allNotifications.where((n) => !n.isRead).length,
      'myEvents': allEvents.where((e) => e.isRegistered).length,
      'myResources': allResources.where((r) => r.isFavorite).length,
    };
  }

  // Load featured content
  Future<void> _loadFeaturedContent() async {
    // Featured events (upcoming, sorted by date)
    _featuredEvents.value = EventModel.featuredEvents().take(3).toList();

    // Recent resources (latest uploads)
    final allResources = ResourceModel.mockList();
    allResources.sort((a, b) => b.uploadedDate.compareTo(a.uploadedDate));
    _recentResources.value = allResources.take(5).toList();

    // Featured alumni (available for mentorship)
    final availableAlumni = AlumniModel.availableForMentorship();
    availableAlumni.shuffle(); // Random selection
    _featuredAlumni.value = availableAlumni.take(3).toList();

    // Recent notifications (unread)
    _recentNotifications.value = NotificationModel.unreadNotifications()
        .take(3)
        .toList();
  }

  // Get stat value
  int getStat(String key) {
    return _stats[key] ?? 0;
  }

  // Refresh dashboard
  Future<void> refreshDashboard() async {
    await loadDashboardData();
  }

  // Quick action methods
  void navigateToEvents() {
    Get.toNamed('/events');
  }

  void navigateToResources() {
    Get.toNamed('/resources');
  }

  void navigateToAlumni() {
    Get.toNamed('/alumni');
  }

  void navigateToNotifications() {
    Get.toNamed('/news');
  }

  void navigateToProfile() {
    Get.toNamed('/profile');
  }

  // Get activity summary
  String getActivitySummary() {
    final registeredEvents = getStat('myEvents');
    final favoriteResources = getStat('myResources');
    final unreadNotifications = getStat('notifications');

    if (registeredEvents == 0 && favoriteResources == 0) {
      return 'Start exploring events and resources!';
    }

    List<String> parts = [];
    if (registeredEvents > 0) {
      parts.add('$registeredEvents event${registeredEvents == 1 ? '' : 's'}');
    }
    if (favoriteResources > 0) {
      parts.add(
        '$favoriteResources saved resource${favoriteResources == 1 ? '' : 's'}',
      );
    }
    if (unreadNotifications > 0) {
      parts.add(
        '$unreadNotifications new notification${unreadNotifications == 1 ? '' : 's'}',
      );
    }

    return parts.join(' • ');
  }

  // Get progress percentage (mock)
  double getProgressPercentage() {
    // Calculate based on activity
    final total = getStat('myEvents') + getStat('myResources');
    return (total / 10).clamp(0.0, 1.0); // Max 10 activities = 100%
  }

  // Check if user has activity today
  bool hasActivityToday() {
    // Mock check - in real app, check against actual user activity
    return DateTime.now().hour > 8; // Active if after 8 AM
  }

  // Get motivational message
  String getMotivationalMessage() {
    final messages = [
      'Keep learning and growing! 🌱',
      'You\'re doing great! 💪',
      'Knowledge is power! 📚',
      'Stay curious and keep exploring! 🔍',
      'Every day is a learning opportunity! ✨',
      'Connect, learn, and inspire! 🚀',
    ];

    // Return different message based on day of week
    return messages[DateTime.now().weekday % messages.length];
  }

  // Update user profile (for future use)
  void updateUserProfile(UserModel updatedUser) {
    _currentUser.value = updatedUser;
  }
}
