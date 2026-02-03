// lib/features/events/controllers/events_controller.dart
import 'package:get/get.dart';
import 'package:kc_connect/core/models/event_model.dart';

class EventsController extends GetxController {
  // Reactive state
  final _allEvents = <EventModel>[].obs;
  final _filteredEvents = <EventModel>[].obs;
  final _searchQuery = ''.obs;
  final _selectedTypeFilter = 'All'.obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final _registeredEventIds = <String>[].obs;

  // Event types for filtering
  final List<String> eventTypes = [
    'All',
    'Workshop',
    'Seminar',
    'Competition',
    'Networking',
    'Social',
  ];

  // Getters
  List<EventModel> get allEvents => _allEvents;
  List<EventModel> get filteredEvents => _filteredEvents;
  List<EventModel> get upcomingEvents =>
      _filteredEvents.where((e) => !e.isPast).toList();
  List<EventModel> get featuredEvents =>
      _filteredEvents.where((e) => e.isFeatured && !e.isPast).toList();
  String get searchQuery => _searchQuery.value;
  String get selectedTypeFilter => _selectedTypeFilter.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  List<String> get registeredEventIds => _registeredEventIds;

  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }

  // Load events
  Future<void> loadEvents() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Load mock data (replace with Supabase later)
      _allEvents.value = EventModel.mockList();
      _applyFilters();

      _isLoading.value = false;
    } catch (e) {
      _errorMessage.value = 'Failed to load events: ${e.toString()}';
      _isLoading.value = false;
    }
  }

  // Search events
  void searchEvents(String query) {
    _searchQuery.value = query.toLowerCase();
    _applyFilters();
  }

  // Filter by event type
  void filterByType(String type) {
    _selectedTypeFilter.value = type;
    _applyFilters();
  }

  // Apply all filters
  void _applyFilters() {
    var filtered = _allEvents.toList();

    // Filter out past events by default
    filtered = filtered.where((e) => !e.isPast).toList();

    // Filter by event type
    if (_selectedTypeFilter.value != 'All') {
      filtered = filtered
          .where((e) => e.type == _selectedTypeFilter.value)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.value.isNotEmpty) {
      filtered = filtered.where((e) {
        return e.title.toLowerCase().contains(_searchQuery.value) ||
            e.description.toLowerCase().contains(_searchQuery.value) ||
            (e.host?.toLowerCase().contains(_searchQuery.value) ?? false);
      }).toList();
    }

    // Sort by date (earliest first)
    filtered.sort((a, b) => a.date.compareTo(b.date));

    _filteredEvents.value = filtered;
  }

  // Register for event
  Future<void> registerForEvent(String eventId) async {
    try {
      final event = _allEvents.firstWhere((e) => e.id == eventId);

      // Check if already registered
      if (_registeredEventIds.contains(eventId)) {
        Get.snackbar(
          'Already Registered',
          'You are already registered for this event',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      // Check if event is full
      if (event.isFull) {
        Get.snackbar(
          'Event Full',
          'Sorry, this event has reached maximum capacity',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      // Simulate registration API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Update registered events list
      _registeredEventIds.add(eventId);

      // Update event registration count and status
      final index = _allEvents.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        _allEvents[index] = event.copyWith(
          registeredCount: event.registeredCount + 1,
          isRegistered: true,
        );
        _applyFilters();
      }

      Get.snackbar(
        'Registration Successful',
        'You have been registered for ${event.title}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Registration Failed',
        'Failed to register for event. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Unregister from event
  Future<void> unregisterFromEvent(String eventId) async {
    try {
      final event = _allEvents.firstWhere((e) => e.id == eventId);

      // Simulate unregister API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Update registered events list
      _registeredEventIds.remove(eventId);

      // Update event registration count and status
      final index = _allEvents.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        _allEvents[index] = event.copyWith(
          registeredCount: event.registeredCount - 1,
          isRegistered: false,
        );
        _applyFilters();
      }

      Get.snackbar(
        'Unregistered',
        'You have been unregistered from ${event.title}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to unregister from event',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Check if user is registered for event
  bool isRegistered(String eventId) {
    return _registeredEventIds.contains(eventId);
  }

  // Get registered events
  List<EventModel> getRegisteredEvents() {
    return _allEvents.where((e) => _registeredEventIds.contains(e.id)).toList();
  }

  // Refresh events
  Future<void> refreshEvents() async {
    await loadEvents();
  }

  // Reset filters
  void resetFilters() {
    _searchQuery.value = '';
    _selectedTypeFilter.value = 'All';
    _applyFilters();
  }

  // Get event count by type
  int getEventCountByType(String type) {
    if (type == 'All') {
      return upcomingEvents.length;
    }
    return upcomingEvents.where((e) => e.type == type).length;
  }
}
