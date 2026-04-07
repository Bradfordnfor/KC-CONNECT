import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  XFile? _pickedImage;
  int _imageSizeBytes = 0;
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
                    ? '${_pickedImage!.name.split('/').last.split('\\').last}  '
                        '(${FileSizeValidator.formatBytes(_imageSizeBytes)})'
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
                message: 'Uploading image...',
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
    final result = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 40,
      maxWidth: 800,
    );
    if (result != null) {
      final size = await result.length();
      final sizeError = FileSizeValidator.validate(size, 5);
      if (sizeError != null) {
        AppSnackbar.error('Image Too Large', sizeError);
        return;
      }
      setState(() {
        _pickedImage = result;
        _imageSizeBytes = size;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedImage == null) {
      AppSnackbar.error('No Image', 'Please select a product image');
      return;
    }

    setState(() => _isUploading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('Not authenticated');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = _pickedImage!.name.split('/').last.split('\\').last;
      final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final storagePath = '$userId/${timestamp}_$safeName';

      await Supabase.instance.client.storage
          .from('product_images')
          .upload(
            storagePath,
            File(_pickedImage!.path),
            fileOptions: const FileOptions(upsert: false),
          );

      final imageUrl = Supabase.instance.client.storage
          .from('product_images')
          .getPublicUrl(storagePath);

      await Supabase.instance.client.from('products').insert({
        'name': _nameController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'description': _descriptionController.text.trim(),
        'stock_quantity': int.parse(_stockController.text.trim()),
        'primary_image_url': imageUrl,
        'category': _selectedCategory,
        'status': 'active',
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
