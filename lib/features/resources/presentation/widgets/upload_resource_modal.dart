// lib/views/resources/widgets/upload_resource_modal.dart
import 'package:flutter/material.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/utils/validators.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';

class UploadResourceModal extends StatefulWidget {
  const UploadResourceModal({super.key});

  @override
  State<UploadResourceModal> createState() => _UploadResourceModalState();
}

class _UploadResourceModalState extends State<UploadResourceModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  String _subject = 'Mathematics';
  String _category = 'O/L';
  String? _selectedFileName;
  bool _isUploading = false;

  final _subjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
    'Literature',
    'History',
    'Geography',
    'Self Development',
  ];

  final _categories = ['O/L', 'A/L', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              label: 'Resource Title',
              hint: 'Enter resource title',
              controller: _titleController,
              validator: (value) => Validators.required(value, 'Title'),
            ),
            const SizedBox(height: 16),

            _buildDropdown(
              label: 'Subject',
              value: _subject,
              items: _subjects,
              onChanged: (v) => setState(() => _subject = v!),
            ),
            const SizedBox(height: 16),

            _buildDropdown(
              label: 'Category',
              value: _category,
              items: _categories,
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),

            // File Selection
            OutlinedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file),
              label: Text(_selectedFileName ?? 'Select File (PDF/DOCX)'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: AppColors.blue),
              ),
            ),

            if (_isUploading) ...[
              const SizedBox(height: 16),
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.blue),
                    SizedBox(height: 8),
                    Text('Uploading...'),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Upload Resource',
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

  void _pickFile() {
    // TODO: Implement file_picker
    setState(() => _selectedFileName = 'sample_document.pdf');
    AppSnackbar.info('File Selected', 'File picker will be implemented');
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedFileName == null) {
        AppSnackbar.error('No File', 'Please select a file');
        return;
      }

      setState(() => _isUploading = true);

      // TODO: Upload to Supabase
      // Get uploader name from auth: authController.currentUser.name
      await Future.delayed(const Duration(seconds: 2));

      setState(() => _isUploading = false);
      AppSnackbar.success('Success', 'Resource uploaded');
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}

void showUploadResourceModal(BuildContext context) {
  AppBottomSheet.show(
    context: context,
    title: 'Upload Resource',
    child: const UploadResourceModal(),
  );
}
