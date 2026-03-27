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
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  String _eventType = 'workshop';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSubmitting = false;

  // DB-accepted event types (lowercase)
  final _eventTypes = ['workshop', 'seminar', 'lesson', 'social', 'webinar'];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              label: 'Title',
              hint: 'Enter event title',
              controller: _titleController,
              validator: (value) => Validators.required(value, 'Title'),
            ),
            const SizedBox(height: 16),

            _buildDropdown(
              label: 'Type',
              value: _eventType,
              items: _eventTypes,
              displayLabel: (v) => v[0].toUpperCase() + v.substring(1),
              onChanged: (value) => setState(() => _eventType = value!),
            ),
            const SizedBox(height: 16),

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
                    suffixIcon: const Icon(
                      Icons.calendar_today,
                      color: AppColors.blue,
                    ),
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
                    suffixIcon: const Icon(
                      Icons.access_time,
                      color: AppColors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            AppMultilineField(
              label: 'Description',
              hint: 'Enter event description',
              controller: _descriptionController,
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 16),

            AppTextField(
              label: 'Location',
              hint: 'Enter event location',
              controller: _locationController,
              validator: (value) => Validators.required(value, 'Location'),
            ),
            const SizedBox(height: 8),

            // Fixed fee notice
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payments_outlined, color: AppColors.blue, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Registration fee: XAF 500',
                    style: TextStyle(
                      color: AppColors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

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
            return DropdownMenuItem(value: item, child: Text(displayLabel(item)));
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

    setState(() => _isSubmitting = true);

    try {
      final authController = Get.find<AuthController>();
      final hostName = authController.currentUser?['full_name'] as String? ?? 'KC Connect';
      final organizerId = Supabase.instance.client.auth.currentUser?.id;

      final startDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      await Supabase.instance.client.from('events').insert({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'event_type': _eventType,
        'start_date': startDate.toIso8601String(),
        'venue': _locationController.text.trim(),
        'host_name': hostName,
        'organized_by': organizerId,
        'registration_fee': 500,
        'requires_registration': true,
        'status': 'upcoming',
        'visibility': 'public',
      });

      if (mounted) Navigator.pop(context);
      AppSnackbar.success('Created', 'Event created successfully');
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to create event');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
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
