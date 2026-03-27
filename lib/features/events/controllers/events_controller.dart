// lib/features/events/controllers/events_controller.dart
import 'package:get/get.dart';
import 'package:kc_connect/core/models/event_model.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventsController extends GetxController {
  final _allEvents = <EventModel>[].obs;
  final _filteredEvents = <EventModel>[].obs;
  final _searchQuery = ''.obs;
  final _selectedTypeFilter = 'All'.obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final _registeredEventIds = <String>[].obs;

  final List<String> eventTypes = [
    'All',
    'Workshop',
    'Seminar',
    'Lesson',
    'Social',
    'Webinar',
  ];

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

  Future<void> loadEvents() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      await Future.wait([_fetchEvents(), _loadRegisteredEventIds()]);
      _isLoading.value = false;
    } catch (e) {
      _errorMessage.value = 'Failed to load events';
      _isLoading.value = false;
    }
  }

  Future<void> _fetchEvents() async {
    final response = await Supabase.instance.client
        .from('events')
        .select()
        .neq('status', 'cancelled')
        .neq('status', 'draft')
        .gte('start_date', DateTime.now().toIso8601String())
        .order('start_date');

    _allEvents.value = (response as List).map(_fromRow).toList();
    _applyFilters();
  }

  Future<void> _loadRegisteredEventIds() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final response = await Supabase.instance.client
        .from('event_registrations')
        .select('event_id')
        .eq('user_id', userId)
        .eq('status', 'registered');
    _registeredEventIds.value =
        (response as List).map((r) => r['event_id'] as String).toList();
  }

  void searchEvents(String query) {
    _searchQuery.value = query.toLowerCase();
    _applyFilters();
  }

  void filterByType(String type) {
    _selectedTypeFilter.value = type;
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = _allEvents.toList();

    if (_selectedTypeFilter.value != 'All') {
      filtered =
          filtered.where((e) => e.type == _selectedTypeFilter.value).toList();
    }

    if (_searchQuery.value.isNotEmpty) {
      filtered = filtered.where((e) {
        return e.title.toLowerCase().contains(_searchQuery.value) ||
            e.description.toLowerCase().contains(_searchQuery.value) ||
            (e.host?.toLowerCase().contains(_searchQuery.value) ?? false);
      }).toList();
    }

    filtered.sort((a, b) => a.date.compareTo(b.date));
    _filteredEvents.value = filtered;
  }

  Future<void> registerForEvent(String eventId) async {
    try {
      final event = _allEvents.firstWhere((e) => e.id == eventId);

      if (_registeredEventIds.contains(eventId)) {
        AppSnackbar.info(
          'Already Registered',
          'You are already registered for ${event.title}',
        );
        return;
      }

      if (event.isFull) {
        AppSnackbar.error(
          'Event Full',
          'This event has reached maximum capacity',
        );
        return;
      }

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        AppSnackbar.error('Not Signed In', 'Please sign in to register');
        return;
      }

      await Future.wait([
        Supabase.instance.client.from('event_registrations').insert({
          'event_id': eventId,
          'user_id': userId,
          'status': 'registered',
          'payment_status':
              event.isPaid ? 'pending' : 'not_required',
          'registration_date': DateTime.now().toIso8601String(),
        }),
        Supabase.instance.client
            .from('events')
            .update({'current_registrations': event.registeredCount + 1})
            .eq('id', eventId),
      ]);

      _registeredEventIds.add(eventId);
      final index = _allEvents.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        _allEvents[index] =
            event.copyWith(registeredCount: event.registeredCount + 1);
        _applyFilters();
      }

      AppSnackbar.success(
        'Registered!',
        'You have been registered for ${event.title}',
      );
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to register. Please try again.');
    }
  }

  Future<void> unregisterFromEvent(String eventId) async {
    try {
      final event = _allEvents.firstWhere((e) => e.id == eventId);
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      await Future.wait([
        Supabase.instance.client
            .from('event_registrations')
            .update({
              'status': 'cancelled',
              'cancelled_at': DateTime.now().toIso8601String(),
            })
            .eq('event_id', eventId)
            .eq('user_id', userId),
        Supabase.instance.client
            .from('events')
            .update({
              'current_registrations': (event.registeredCount - 1).clamp(0, 999999),
            })
            .eq('id', eventId),
      ]);

      _registeredEventIds.remove(eventId);
      final index = _allEvents.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        _allEvents[index] = event.copyWith(
          registeredCount: (event.registeredCount - 1).clamp(0, 999999),
        );
        _applyFilters();
      }

      AppSnackbar.info(
        'Unregistered',
        'You have been unregistered from ${event.title}',
      );
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to unregister from event');
    }
  }

  bool isRegistered(String eventId) => _registeredEventIds.contains(eventId);

  List<EventModel> getRegisteredEvents() =>
      _allEvents.where((e) => _registeredEventIds.contains(e.id)).toList();

  Future<void> refreshEvents() => loadEvents();

  void resetFilters() {
    _searchQuery.value = '';
    _selectedTypeFilter.value = 'All';
    _applyFilters();
  }

  int getEventCountByType(String type) {
    if (type == 'All') return upcomingEvents.length;
    return upcomingEvents.where((e) => e.type == type).length;
  }

  // ─── Mapper ─────────────────────────────────────────────────────────────────

  EventModel _fromRow(dynamic row) {
    final r = row as Map<String, dynamic>;
    final startDate =
        DateTime.tryParse(r['start_date'] ?? '') ?? DateTime.now();
    return EventModel(
      id: r['id'] ?? '',
      title: r['title'] ?? '',
      description: r['description'] ?? '',
      type: _capitalise(r['event_type'] ?? 'other'),
      date: startDate,
      time:
          '${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')}',
      host: r['host_name'],
      location: r['venue'],
      imageUrl: r['banner_image_url'],
      capacity: r['max_capacity'],
      registeredCount: r['current_registrations'] ?? 0,
      isFeatured: r['is_featured'] ?? false,
      registrationFee: (r['registration_fee'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String _capitalise(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
