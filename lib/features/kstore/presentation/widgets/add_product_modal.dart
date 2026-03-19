// lib/views/k_store/widgets/add_product_modal.dart
import 'package:flutter/material.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/utils/validators.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';

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

  String? _selectedImageName;
  bool _isUploading = false;

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

            // Image Selection
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: Text(_selectedImageName ?? 'Select Product Image'),
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

  void _pickImage() {
    // TODO: Implement image_picker
    setState(() => _selectedImageName = 'product_image.jpg');
    AppSnackbar.info('Image Selected', 'Image picker will be implemented');
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImageName == null) {
        AppSnackbar.error('No Image', 'Please select a product image');
        return;
      }

      setState(() => _isUploading = true);

      // TODO: Upload to Supabase
      await Future.delayed(const Duration(seconds: 2));

      setState(() => _isUploading = false);
      AppSnackbar.success('Success', 'Product added');
      Navigator.pop(context);
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
