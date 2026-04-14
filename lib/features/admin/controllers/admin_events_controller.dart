import 'package:get/get.dart';
import 'package:kc_connect/core/models/event_model.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const double kDefaultRegistrationFee = 500.0;

class AdminEventsController extends GetxController {
  final _events = <EventModel>[].obs;
  final _isLoading = false.obs;

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }

  Future<void> loadEvents() async {
    try {
      _isLoading.value = true;
      final response = await Supabase.instance.client
          .from('events')
          .select()
          .neq('status', 'cancelled')
          .order('start_date', ascending: false);

      _events.value =
          (response as List).map((r) => _fromRow(r as Map<String, dynamic>)).toList();
      _isLoading.value = false;
    } catch (e) {
      _isLoading.value = false;
      AppSnackbar.error('Error', 'Failed to load events');
    }
  }

  Future<void> togglePaidStatus(String eventId, bool isPaid) async {
    try {
      final fee = isPaid ? kDefaultRegistrationFee : 0.0;
      await Supabase.instance.client
          .from('events')
          .update({'registration_fee': fee})
          .eq('id', eventId);

      final index = _events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        _events[index] = _events[index].copyWith(registrationFee: fee);
      }
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to update event fee');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      final event = _events.firstWhere((e) => e.id == eventId);
      await Supabase.instance.client
          .from('events')
          .update({'status': 'cancelled'})
          .eq('id', eventId);

      _events.removeWhere((e) => e.id == eventId);
      AppSnackbar.success('Cancelled', '${event.title} has been cancelled');
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to delete event');
    }
  }

  Future<void> refreshEvents() => loadEvents();

  // ─── Mapper ─────────────────────────────────────────────────────────────────

  EventModel _fromRow(Map<String, dynamic> r) {
    final startDate = DateTime.tryParse(r['start_date'] ?? '') ?? DateTime.now();
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
