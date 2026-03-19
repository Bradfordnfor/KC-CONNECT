import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';

/// Uniform text field component for forms
///
/// Usage:
/// ```dart
/// AppTextField(
///   label: 'Title',
///   hint: 'Enter event title',
///   controller: titleController,
///   validator: (value) => value!.isEmpty ? 'Required' : null,
/// )
/// ```
class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final String? initialValue;

  const AppTextField({
    Key? key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.inputFormatters,
    this.initialValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.blue,
          ),
        ),
        const SizedBox(height: 8),

        // Text field
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines,
          maxLength: maxLength,
          enabled: enabled,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.textLight),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.blue.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.blue.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.blue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.textLight.withOpacity(0.2),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            counterText: '', // Hide character counter
          ),
        ),
      ],
    );
  }
}

/// Multiline text field (for descriptions, bio, etc.)
class AppMultilineField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final int minLines;
  final int maxLines;
  final int? maxLength;

  const AppMultilineField({
    Key? key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.minLines = 3,
    this.maxLines = 5,
    this.maxLength,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      hint: hint,
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: TextInputType.multiline,
    );
  }
}
