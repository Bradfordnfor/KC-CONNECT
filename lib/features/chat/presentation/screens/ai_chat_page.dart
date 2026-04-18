import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/common/snackbar.dart';
import 'package:kc_connect/features/chat/controllers/ai_chat_controller.dart';

class AIChatPage extends StatelessWidget {
  const AIChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AiChatController(), permanent: true);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.blue),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                gradient: AppColors.gradientColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: AppColors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KC Connect AI',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Always here to help',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => controller.messages.isEmpty
                  ? _buildEmptyState(controller)
                  : _buildMessageList(controller),
            ),
          ),
          _buildInputArea(context, controller),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AiChatController controller) {
    final firstName = controller.userFirstName;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                gradient: AppColors.gradientColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: AppColors.white, size: 54),
            ),
            const SizedBox(height: 20),
            Text(
              'Hi, $firstName!',
              style: AppTextStyles.subHeading.copyWith(
                color: AppColors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'How can KC Connect AI help you today?',
              style: AppTextStyles.body.copyWith(
                color: Colors.grey[600],
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Text(
              'Try asking:',
              style: AppTextStyles.caption.copyWith(
                color: Colors.grey[500],
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: controller.suggestedPrompts
                  .map((p) => _buildSuggestedPrompt(controller, p))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedPrompt(AiChatController controller, String text) {
    return InkWell(
      onTap: () => controller.sendSuggestedPrompt(text),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.blue.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.blue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList(AiChatController controller) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: controller.messages.length,
      itemBuilder: (context, index) {
        final message = controller.messages[index];
        return _buildMessageBubble(context, message.text, message.isUser);
      },
    );
  }

  Widget _buildMessageBubble(BuildContext context, String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: text));
          AppSnackbar.info('Copied', 'Message copied to clipboard');
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: BoxConstraints(maxWidth: Get.width * 0.75),
          decoration: BoxDecoration(
            color: isUser ? AppColors.blue : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            style: AppTextStyles.body.copyWith(
              color: isUser ? AppColors.white : Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, AiChatController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Attachment button
          Obx(() => IconButton(
                icon: const Icon(Icons.attach_file, color: AppColors.blue),
                onPressed: controller.isSending
                    ? null
                    : () => _showAttachmentOptions(context, controller),
              )),

          // Text input
          Expanded(
            child: TextField(
              controller: controller.messageController,
              decoration: InputDecoration(
                hintText: 'Ask me anything...',
                hintStyle:
                    AppTextStyles.body.copyWith(color: Colors.grey, fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide:
                      BorderSide(color: AppColors.blue.withValues(alpha: 0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide:
                      BorderSide(color: AppColors.blue.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.blue),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => controller.sendMessage(),
            ),
          ),

          const SizedBox(width: 8),

          // Send button
          Obx(() => Container(
                decoration: BoxDecoration(
                  gradient: AppColors.gradientColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: controller.isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send, color: AppColors.white),
                  onPressed:
                      controller.isSending ? null : () => controller.sendMessage(),
                ),
              )),
        ],
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context, AiChatController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // PDF notice
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.blue, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Only PDF documents are supported for file uploads.',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.blue, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: AppColors.red),
              title: const Text('Upload PDF Document'),
              subtitle: const Text('Coming soon'),
              onTap: () {
                Navigator.pop(context);
                AppSnackbar.info('Coming Soon', 'File upload will be available in the next update.');
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.blue),
              title: const Text('Take a Photo'),
              subtitle: const Text('Coming soon'),
              onTap: () {
                Navigator.pop(context);
                AppSnackbar.info('Coming Soon', 'Image upload will be available in the next update.');
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.blue),
              title: const Text('Choose from Gallery'),
              subtitle: const Text('Coming soon'),
              onTap: () {
                Navigator.pop(context);
                AppSnackbar.info('Coming Soon', 'Image upload will be available in the next update.');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
