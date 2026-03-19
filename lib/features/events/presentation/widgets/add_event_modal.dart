// lib/views/events/widgets/add_event_modal.dart
import 'package:flutter/material.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/utils/validators.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';

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

  String _eventType = 'Workshop';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final _eventTypes = ['Workshop', 'Seminar', 'Social', 'Conference', 'Other'];

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
              onChanged: (value) => setState(() => _eventType = value!),
            ),
            const SizedBox(height: 16),

            // Date & Time
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
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
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
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
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

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null || _selectedTime == null) {
        AppSnackbar.error('Missing Info', 'Please select date and time');
        return;
      }

      // TODO: Add to Supabase
      // Get host name from auth: authController.currentUser.name
      AppSnackbar.success('Success', 'Event created');
      Navigator.pop(context);
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
