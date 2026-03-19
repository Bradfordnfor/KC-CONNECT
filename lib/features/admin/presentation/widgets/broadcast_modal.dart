// lib/views/admin/widgets/broadcast_modal.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/utils/validators.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
import 'package:kc_connect/features/admin/controllers/admin_broadcast_controller.dart';

class BroadcastModal extends StatefulWidget {
  const BroadcastModal({Key? key}) : super(key: key);

  @override
  State<BroadcastModal> createState() => _BroadcastModalState();
}

class _BroadcastModalState extends State<BroadcastModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final controller = Get.put(AdminBroadcastController());

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
              hint: 'Enter announcement title',
              controller: _titleController,
              validator: (value) => Validators.required(value, 'Title'),
            ),
            const SizedBox(height: 16),

            AppMultilineField(
              label: 'Message',
              hint: 'Enter announcement message',
              controller: _messageController,
              minLines: 4,
              maxLines: 6,
              validator: (value) => Validators.required(value, 'Message'),
            ),
            const SizedBox(height: 16),

            // Target Audience
            Text(
              'Target Audience',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.blue,
              ),
            ),
            const SizedBox(height: 12),

            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.audiences.map((audience) {
                  final isSelected = controller.isAudienceSelected(audience);
                  final isEveryone = audience == 'Everyone';
                  final everyoneSelected = controller.isAudienceSelected(
                    'Everyone',
                  );

                  return FilterChip(
                    label: Text(audience),
                    selected: isSelected,
                    onSelected: everyoneSelected && !isEveryone
                        ? null
                        : (selected) => controller.toggleAudience(audience),
                    backgroundColor: AppColors.backgroundColor,
                    selectedColor: AppColors.blue,
                    disabledColor: AppColors.backgroundColor.withOpacity(0.5),
                    labelStyle: AppTextStyles.body.copyWith(
                      color: isSelected ? AppColors.white : AppColors.blue,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    checkmarkColor: AppColors.white,
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Send Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isSending ? null : _handleSend,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: controller.isSending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Send Announcement',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSend() {
    if (_formKey.currentState!.validate()) {
      controller.sendBroadcast(
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    controller.resetSelections();
    super.dispose();
  }
}

void showBroadcastModal(BuildContext context) {
  AppBottomSheet.show(
    context: context,
    title: 'Broadcast Announcement',
    child: const BroadcastModal(),
  );
}
