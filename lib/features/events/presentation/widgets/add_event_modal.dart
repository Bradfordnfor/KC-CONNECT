// lib/views/events/widgets/add_event_modal.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/utils/validators.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
import 'package:kc_connect/features/auth/controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddEventModal extends StatefulWidget {
  const AddEventModal({super.key});

  @override
  State<AddEventModal> createState() => _AddEventModalState();
}

class _AddEventModalState extends State<AddEventModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController       = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venueController       = TextEditingController(); // Onsite only
  final _meetingLinkController = TextEditingController(); // Online only
  final _customTypeController  = TextEditingController();

  String _eventType    = 'workshop';
  String _locationType = 'Onsite'; // 'Online' | 'Onsite'
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSubmitting = false;

  final _eventTypes = [
    'workshop', 'seminar', 'lesson', 'social', 'webinar', 'others',
  ];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            AppTextField(
              label: 'Title',
              hint: 'Enter event title',
              controller: _titleController,
              validator: (value) => Validators.required(value, 'Title'),
            ),
            const SizedBox(height: 16),

            // Event type dropdown
            _buildDropdown(
              label: 'Type',
              value: _eventType,
              items: _eventTypes,
              displayLabel: (v) => v[0].toUpperCase() + v.substring(1),
              onChanged: (value) => setState(() => _eventType = value!),
            ),
            if (_eventType == 'others') ...[
              const SizedBox(height: 12),
              AppTextField(
                label: 'Custom Event Type',
                hint: 'e.g. Conference, Exhibition...',
                controller: _customTypeController,
                validator: (v) => Validators.required(v, 'Event type'),
              ),
            ],
            const SizedBox(height: 16),

            // Date / Time row
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Date',
                    hint: 'Select date',
                    readOnly: true,
                    controller: TextEditingController(
                      text: _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : '',
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) setState(() => _selectedDate = date);
                    },
                    suffixIcon: const Icon(Icons.calendar_today, color: AppColors.blue),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'Time',
                    hint: 'Select time',
                    readOnly: true,
                    controller: TextEditingController(
                      text: _selectedTime != null
                          ? _selectedTime!.format(context)
                          : '',
                    ),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) setState(() => _selectedTime = time);
                    },
                    suffixIcon: const Icon(Icons.access_time, color: AppColors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            AppMultilineField(
              label: 'Description',
              hint: 'Enter event description',
              controller: _descriptionController,
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 16),

            // Location type dropdown
            _buildDropdown(
              label: 'Location Type',
              value: _locationType,
              items: const ['Onsite', 'Online'],
              displayLabel: (v) => v,
              onChanged: (value) => setState(() => _locationType = value!),
            ),
            const SizedBox(height: 12),

            // Conditional: Onsite → venue field / Online → meeting link field
            if (_locationType == 'Onsite')
              AppTextField(
                label: 'Venue',
                hint: 'e.g. KC Main Hall, Room 101...',
                controller: _venueController,
                validator: (v) => Validators.required(v, 'Venue'),
                prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.blue),
              )
            else
              AppTextField(
                label: 'Meeting Link',
                hint: 'https://zoom.us/j/... or meet.google.com/...',
                controller: _meetingLinkController,
                keyboardType: TextInputType.url,
                validator: (v) => Validators.required(v, 'Meeting link'),
                prefixIcon: const Icon(Icons.videocam_outlined, color: AppColors.blue),
              ),
            const SizedBox(height: 8),

            // Fee notice
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.payments_outlined, color: AppColors.blue, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Registration fee: XAF 20',
                    style: TextStyle(
                      color: AppColors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Create Event',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required String Function(String) displayLabel,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.blue,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(displayLabel(item)),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      AppSnackbar.error('Missing Info', 'Please select date and time');
      return;
    }
    if (_eventType == 'others' && _customTypeController.text.trim().isEmpty) {
      AppSnackbar.error('Missing Info', 'Please enter a custom event type');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authController = Get.find<AuthController>();
      final hostName       = authController.currentUser?['full_name'] as String? ?? 'KC Connect';
      final organizerRole  = authController.currentUser?['role']      as String? ?? 'staff';
      final organizerId    = Supabase.instance.client.auth.currentUser?.id;

      final startDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      final endDate = startDate.add(const Duration(hours: 2));

      final isOnline = _locationType == 'Online';

      await Supabase.instance.client.from('events').insert({
        'title':                  _titleController.text.trim(),
        'description':            _descriptionController.text.trim(),
        'event_type':             _eventType == 'others'
            ? _customTypeController.text.trim().toLowerCase()
            : _eventType,
        'start_date':             startDate.toIso8601String(),
        'end_date':               endDate.toIso8601String(),
        'venue':                  isOnline ? 'Online' : _venueController.text.trim(),
        'host_name':              hostName,
        'organized_by':           organizerId,
        'organizer_role':         organizerRole,
        'registration_fee':       20,
        'requires_registration':  true,
        'status':                 'upcoming',
        'visibility':             'public',
        if (isOnline)
          'meeting_link': _meetingLinkController.text.trim(),
      });

      if (mounted) Navigator.pop(context);
      AppSnackbar.success('Created', 'Event created successfully');
    } catch (e) {
      debugPrint('Create event error: $e');
      AppSnackbar.error('Error', 'Failed to create event');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _meetingLinkController.dispose();
    _customTypeController.dispose();
    super.dispose();
  }
}

void showAddEventModal(BuildContext context) {
  AppBottomSheet.show(
    context: context,
    title: 'Add Event',
    child: const AddEventModal(),
  );
}
