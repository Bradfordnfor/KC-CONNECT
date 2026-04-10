import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/utils/validators.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
import 'package:kc_connect/features/auth/controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadResourceModal extends StatefulWidget {
  const UploadResourceModal({super.key});

  @override
  State<UploadResourceModal> createState() => _UploadResourceModalState();
}

class _UploadResourceModalState extends State<UploadResourceModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _subject = 'Mathematics';
  String _category = 'O/L';
  PlatformFile? _pickedFile;
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

  final _categories = ['O/L', 'A/L', 'Other Books'];

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

            AppMultilineField(
              label: 'Description (optional)',
              hint: 'Brief description of this resource',
              controller: _descriptionController,
              minLines: 2,
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // File picker button
            OutlinedButton.icon(
              onPressed: _isUploading ? null : _pickFile,
              icon: Icon(
                _pickedFile != null ? Icons.check_circle : Icons.attach_file,
                color: _pickedFile != null ? AppColors.success : AppColors.blue,
              ),
              label: Text(
                _pickedFile != null
                    ? '${_pickedFile!.name}  '
                        '(${FileSizeValidator.formatBytes(_pickedFile!.size)})'
                    : 'Select File (PDF / DOCX)',
                overflow: TextOverflow.ellipsis,
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: BorderSide(
                  color:
                      _pickedFile != null ? AppColors.success : AppColors.blue,
                ),
              ),
            ),

            if (_isUploading) ...[
              const SizedBox(height: 16),
              AppUploadingIndicator(
                message: 'Uploading ${_pickedFile?.name ?? 'file'}...',
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
          initialValue: value,
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

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'doc'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      final sizeError = FileSizeValidator.validate(file.size, 20);
      if (sizeError != null) {
        AppSnackbar.error('File Too Large', sizeError);
        return;
      }
      setState(() => _pickedFile = file);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedFile == null || _pickedFile!.bytes == null) {
      AppSnackbar.error('No File', 'Please select a file to upload');
      return;
    }

    setState(() => _isUploading = true);

    try {
      final authController = Get.find<AuthController>();
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('Not authenticated');

      final uploaderName =
          authController.currentUser?['full_name'] as String? ?? 'Admin';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final safeName =
          _pickedFile!.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final storagePath = '$userId/${timestamp}_$safeName';

      final fileExt = _pickedFile!.name.split('.').last.toLowerCase();
      final contentType = switch (fileExt) {
        'pdf'  => 'application/pdf',
        'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'doc'  => 'application/msword',
        _      => 'application/octet-stream',
      };

      await Supabase.instance.client.storage
          .from('resources')
          .uploadBinary(
            storagePath,
            _pickedFile!.bytes!,
            fileOptions: FileOptions(upsert: false, contentType: contentType),
          );

      // Bucket is public — store the permanent public URL so it can be used
      // directly without any signed-URL generation at open time.
      final publicUrl = Supabase.instance.client.storage
          .from('resources')
          .getPublicUrl(storagePath);

      await Supabase.instance.client.from('resources').insert({
        'title': _titleController.text.trim(),
        'subject': _subject,
        'category': _category,
        'description': _descriptionController.text.trim(),
        'file_url': publicUrl,
        'file_name': _pickedFile!.name,
        'file_type': _pickedFile!.name.split('.').last.toLowerCase(),
        'file_size': _pickedFile!.size,
        'uploader_role': Get.find<AuthController>().currentUser?['role'] as String? ?? 'staff',
        'uploaded_by': userId,
        'uploader_name': uploaderName,
        'download_count': 0,
        'status': 'active',
      });

      if (mounted) Navigator.pop(context);
      AppSnackbar.success('Uploaded', 'Resource uploaded successfully');
    } catch (e) {
      debugPrint('Upload resource error: $e');
      AppSnackbar.error('Upload Failed', e.toString());
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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
