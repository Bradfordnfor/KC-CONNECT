import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/utils/validators.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddProductModal extends StatefulWidget {
  const AddProductModal({super.key});

  @override
  State<AddProductModal> createState() => _AddProductModalState();
}

class _AddProductModalState extends State<AddProductModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stockController = TextEditingController();

  PlatformFile? _pickedImage;
  bool _isUploading = false;
  String _selectedCategory = 'clothing';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              label: 'Product Name',
              hint: 'Enter product name',
              controller: _nameController,
              validator: (value) => Validators.required(value, 'Name'),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Price (XAF)',
                    hint: '0',
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    validator: (v) => Validators.number(v, 'Price'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'Stock Quantity',
                    hint: '0',
                    controller: _stockController,
                    keyboardType: TextInputType.number,
                    validator: (v) => Validators.number(v, 'Stock'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            AppMultilineField(
              label: 'Description',
              hint: 'Enter product description',
              controller: _descriptionController,
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              items: const [
                DropdownMenuItem(value: 'clothing', child: Text('Clothing')),
                DropdownMenuItem(value: 'books', child: Text('Books')),
                DropdownMenuItem(value: 'electronics', child: Text('Electronics')),
                DropdownMenuItem(value: 'stationery', child: Text('Stationery')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 16),

            // Image picker button
            OutlinedButton.icon(
              onPressed: _isUploading ? null : _pickImage,
              icon: Icon(
                _pickedImage != null ? Icons.check_circle : Icons.image,
                color:
                    _pickedImage != null ? AppColors.success : AppColors.blue,
              ),
              label: Text(
                _pickedImage != null
                    ? '${_pickedImage!.name}  '
                        '(${FileSizeValidator.formatBytes(_pickedImage!.size)})'
                    : 'Select Product Image',
                overflow: TextOverflow.ellipsis,
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: BorderSide(
                  color: _pickedImage != null
                      ? AppColors.success
                      : AppColors.blue,
                ),
              ),
            ),

            if (_isUploading) ...[
              const SizedBox(height: 16),
              AppUploadingIndicator(
                message: 'Uploading ${_pickedImage?.name ?? 'image'}...',
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
                  'Add Product',
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

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      final sizeError = FileSizeValidator.validate(file.size, 5);
      if (sizeError != null) {
        AppSnackbar.error('Image Too Large', sizeError);
        return;
      }
      setState(() => _pickedImage = file);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedImage == null || _pickedImage!.bytes == null) {
      AppSnackbar.error('No Image', 'Please select a product image');
      return;
    }

    setState(() => _isUploading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('Not authenticated');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final safeName =
          _pickedImage!.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final storagePath = '$userId/${timestamp}_$safeName';

      await Supabase.instance.client.storage
          .from('products')
          .uploadBinary(
            storagePath,
            _pickedImage!.bytes!,
            fileOptions: const FileOptions(upsert: false),
          );

      final imageUrl = Supabase.instance.client.storage
          .from('products')
          .getPublicUrl(storagePath);

      await Supabase.instance.client.from('products').insert({
        'name': _nameController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'description': _descriptionController.text.trim(),
        'stock_quantity': int.parse(_stockController.text.trim()),
        'primary_image_url': imageUrl,
        'category': _selectedCategory,
        'status': 'active',
        'added_by': userId,
      });

      if (mounted) Navigator.pop(context);
      AppSnackbar.success('Added', 'Product added successfully');
    } catch (e) {
      debugPrint('Add product error: $e');
      AppSnackbar.error('Error', 'Failed to add product');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    super.dispose();
  }
}

void showAddProductModal(BuildContext context) {
  AppBottomSheet.show(
    context: context,
    title: 'Add Product',
    child: const AddProductModal(),
  );
}
