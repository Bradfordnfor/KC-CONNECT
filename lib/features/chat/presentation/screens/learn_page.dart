import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/models/message_model.dart';
import 'package:kc_connect/core/routes/app_routes.dart';
import 'package:kc_connect/core/screens/in_app_image_viewer.dart';
import 'package:kc_connect/core/screens/in_app_pdf_viewer.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/carousel_widget.dart';
import 'package:kc_connect/core/widgets/common/all_common_widgets.dart';
import 'package:kc_connect/features/auth/controllers/auth_controller.dart';
import 'package:kc_connect/features/chat/controllers/learn_controller.dart';
import 'package:kc_connect/features/payment/presentation/widgets/subscription_payment_modal.dart';

class LearnPage extends StatelessWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LearnController controller = Get.put(LearnController());

    return DefaultTabController(
      length: 2,
      child: Material(
        color: AppColors.backgroundColor,
        child: Column(
          children: [
            _buildCarouselBanner(),
            const SizedBox(height: 8),
            _buildTabBar(controller),
            Expanded(child: _buildTabBarView(context, controller)),
            _buildReplyBar(controller),
            _buildInputAreaWithAIButton(context, controller),
          ],
        ),
      ),
    );
  }

  // ─── Banner ──────────────────────────────────────────────────────────────

  Widget _buildCarouselBanner() {
    return CarouselWidget(
      height: 150,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      autoPlay: false,
      showIndicators: false,
      items: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.gradientColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                height: 28,
                width: 55,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'chat',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStarBadge(1),
                      const SizedBox(height: 8),
                      _buildStarBadge(2),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Interact with other KCians around the globe',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.normal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Get rewarded for global impact and consistency',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.normal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStarBadge(int number) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.star, color: AppColors.white, size: 18),
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: AppColors.blue,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number.toString(),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tabs ────────────────────────────────────────────────────────────────

  Widget _buildTabBar(LearnController controller) {
    return Container(
      color: Colors.transparent,
      child: TabBar(
        onTap: controller.changeTab,
        labelColor: AppColors.red,
        unselectedLabelColor: AppColors.blue,
        indicatorColor: AppColors.red,
        indicatorWeight: 3,
        labelStyle: AppTextStyles.body.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        tabs: const [
          Tab(text: 'Grade 10'),
          Tab(text: 'Grade 12'),
        ],
      ),
    );
  }

  Widget _buildTabBarView(BuildContext context, LearnController controller) {
    return Obx(() {
      if (controller.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      return IndexedStack(
        index: controller.currentTabIndex,
        children: [
          _buildChatView(context, controller, controller.grade10Messages, 'grade10'),
          _buildChatView(context, controller, controller.grade12Messages, 'grade12'),
        ],
      );
    });
  }

  Widget _buildChatView(
    BuildContext context,
    LearnController controller,
    List messages,
    String room,
  ) {
    return Column(
      children: [
        _buildPinnedBanner(context, controller, room),
        Expanded(
          child: messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: AppColors.blue.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No messages yet',
                        style:
                            AppTextStyles.body.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Be the first to start the conversation!',
                        style: AppTextStyles.caption
                            .copyWith(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller:
                      controller.scrollControllerForRoom(room),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (ctx, index) {
                    final message = messages[index] as MessageModel;
                    return KeyedSubtree(
                      key: controller.keyForMessage(message.id),
                      child: _buildMessageBubble(
                          ctx, message, controller),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ─── Pinned messages banner ───────────────────────────────────────────────

  Widget _buildPinnedBanner(
    BuildContext context,
    LearnController controller,
    String room,
  ) {
    return Obx(() {
      final pinned = controller.pinnedForRoom(room);
      if (pinned.isEmpty) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.fromLTRB(12, 4, 12, 0),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.35)),
        ),
        child: Column(
          children: pinned.asMap().entries.map((entry) {
            final idx = entry.key;
            final pin = entry.value;
            return Column(
              children: [
                if (idx > 0)
                  Divider(
                      height: 1,
                      color: Colors.amber.withValues(alpha: 0.25)),
                GestureDetector(
                  onTap: () => controller.scrollToMessage(pin.messageId, room),
                  onLongPress: () =>
                      _showPinnedDetail(context, pin, controller),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.push_pin,
                            color: Colors.amber, size: 15),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pin.messageSenderName,
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.amber[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                pin.messageContent,
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.black87,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          pin.timeRemainingLabel,
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.grey[500],
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      );
    });
  }

  void _showPinnedDetail(
    BuildContext context,
    PinnedChatMessage pin,
    LearnController controller,
  ) {
    final uid = controller.currentUserId;
    final isPinner = pin.pinnedBy == uid;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.push_pin, color: Colors.amber, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Pinned Message',
                    style: AppTextStyles.subHeading.copyWith(
                        color: AppColors.blue, fontSize: 16),
                  ),
                  const Spacer(),
                  Text(
                    pin.timeRemainingLabel,
                    style: AppTextStyles.caption.copyWith(
                        color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pin.messageSenderName,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pin.messageContent,
                      style: AppTextStyles.body.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pinned by ${pin.pinnerName}',
                style: AppTextStyles.caption
                    .copyWith(color: Colors.grey[500], fontSize: 11),
              ),
              if (isPinner) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      controller.unpinMessage(pin.id);
                      AppSnackbar.info('Unpinned', 'Message unpinned');
                    },
                    icon: const Icon(Icons.push_pin_outlined,
                        color: Colors.red, size: 16),
                    label: const Text('Unpin this message',
                        style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Message bubble ──────────────────────────────────────────────────────

  Widget _buildMessageBubble(
      BuildContext context, MessageModel message, LearnController controller) {
    final isMe = message.isMe;
    final time = _formatTime(message.timestamp);

    Widget bubbleContent;
    if (message.messageType != 'text' &&
        message.status == MessageStatus.sending) {
      bubbleContent = _buildUploadingBubble(isMe);
    } else if (message.messageType != 'text' &&
        message.status == MessageStatus.failed) {
      bubbleContent = _buildFailedFileBubble();
    } else if (message.isImage && message.fileUrl != null) {
      bubbleContent = _buildImageBubble(context, message, isMe, time);
    } else if (message.isFile && message.fileUrl != null) {
      bubbleContent = _buildFileBubble(context, message, isMe, time);
    } else {
      bubbleContent = _buildTextBubble(message, isMe, time);
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: BoxConstraints(maxWidth: Get.width * 0.75),
        child: GestureDetector(
          onLongPress: () =>
              _showMessageOptions(context, message, controller),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMe)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 4),
                  child: Text(
                    message.senderName,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              bubbleContent,
            ],
          ),
        ),
      ),
    );
  }

  // ─── Bubble types ────────────────────────────────────────────────────────

  Widget _buildUploadingBubble(bool isMe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.blue.withValues(alpha: 0.6) : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: isMe ? AppColors.white : AppColors.blue,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Uploading...',
            style: AppTextStyles.caption.copyWith(
              color: isMe ? AppColors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailedFileBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Text(
            'Failed to upload',
            style: AppTextStyles.caption.copyWith(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildTextBubble(MessageModel message, bool isMe, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.blue : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.replyToId != null) _buildReplyQuote(message, isMe),
          Text(
            message.content,
            style: AppTextStyles.body.copyWith(
              color: isMe ? AppColors.white : Colors.black87,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: AppTextStyles.caption.copyWith(
              color: isMe
                  ? AppColors.white.withValues(alpha: 0.8)
                  : Colors.grey[500],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageBubble(
      BuildContext context, MessageModel message, bool isMe, String time) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InAppImageViewer(
            imageUrl: message.fileUrl!,
            title: message.fileName ?? 'Image',
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: message.fileUrl!,
                width: 220,
                height: 200,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 220,
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 220,
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, size: 40),
                ),
              ),
              Positioned(
                bottom: 6,
                right: 8,
                child: Text(
                  time,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                    shadows: const [
                      Shadow(color: Colors.black54, blurRadius: 4),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileBubble(
      BuildContext context, MessageModel message, bool isMe, String time) {
    final ext = (message.fileName ?? '').split('.').last.toLowerCase();
    final isPdf = ext == 'pdf';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.blue : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isMe ? AppColors.white : AppColors.blue)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file,
              color: isMe ? AppColors.white : AppColors.blue,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.fileName ?? 'File',
                  style: AppTextStyles.body.copyWith(
                    color: isMe ? AppColors.white : Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  message.formattedFileSize,
                  style: AppTextStyles.caption.copyWith(
                    color: isMe
                        ? AppColors.white.withValues(alpha: 0.8)
                        : Colors.grey[500],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _openChatFile(context, message),
            child: Icon(
              Icons.open_in_new,
              color: isMe ? AppColors.white : AppColors.blue,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Reply quote ─────────────────────────────────────────────────────────

  Widget _buildReplyQuote(MessageModel message, bool isMe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isMe
            ? Colors.white.withValues(alpha: 0.2)
            : AppColors.blue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: isMe ? AppColors.white : AppColors.blue,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.replyToSenderName ?? 'Unknown',
            style: TextStyle(
              color: isMe
                  ? Colors.white.withValues(alpha: 0.95)
                  : AppColors.blue,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            message.replyToContent ?? '📎 Attachment',
            style: TextStyle(
              color: isMe
                  ? Colors.white.withValues(alpha: 0.75)
                  : Colors.grey[600],
              fontSize: 11,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ─── Reply bar (above input) ─────────────────────────────────────────────

  Widget _buildReplyBar(LearnController controller) {
    return Obx(() {
      final replyingTo = controller.replyingTo;
      if (replyingTo == null) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        decoration: BoxDecoration(
          color: AppColors.blue.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: AppColors.blue.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    replyingTo.senderName,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    replyingTo.content.isNotEmpty
                        ? replyingTo.content
                        : replyingTo.isImage
                            ? '📷 Image'
                            : '📎 File',
                    style: AppTextStyles.caption
                        .copyWith(color: Colors.grey[600], fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.grey),
              onPressed: controller.clearReply,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      );
    });
  }

  // ─── Input area ──────────────────────────────────────────────────────────

  Widget _buildInputAreaWithAIButton(
      BuildContext context, LearnController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: AppColors.blue),
              onPressed: () =>
                  _showAttachmentSheet(context, controller),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller.messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: AppTextStyles.body
                    .copyWith(color: Colors.grey, fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                      color: AppColors.blue.withValues(alpha: 0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                      color: AppColors.blue.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.blue),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (text) {
                if (checkSubscriptionGate()) return;
                controller.sendMessage(text);
              },
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.gradientColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: AppColors.white),
              onPressed: () {
                if (checkSubscriptionGate()) return;
                controller.sendMessage(controller.messageController.text);
              },
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.blue,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              tooltip: 'KC Connect AI',
              icon: const Icon(Icons.auto_awesome,
                  color: AppColors.white, size: 24),
              onPressed: () => Get.toNamed(AppRoutes.aiChat),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Attachment sheet ────────────────────────────────────────────────────

  void _showAttachmentSheet(
      BuildContext context, LearnController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAttachOption(
                icon: Icons.camera_alt,
                label: 'Camera',
                color: AppColors.blue,
                onTap: () {
                  Navigator.pop(context);
                  controller.sendImageFromCamera();
                },
              ),
              _buildAttachOption(
                icon: Icons.photo_library,
                label: 'Gallery',
                color: Colors.purple,
                onTap: () {
                  Navigator.pop(context);
                  controller.sendImageFromGallery();
                },
              ),
              _buildAttachOption(
                icon: Icons.insert_drive_file,
                label: 'File',
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      title: Row(
                        children: const [
                          Icon(Icons.picture_as_pdf,
                              color: AppColors.blue, size: 24),
                          SizedBox(width: 8),
                          Text('PDF Files Only'),
                        ],
                      ),
                      content: const Text(
                          'This platform only accepts PDF files in chat. Please make sure your file is in PDF format before selecting.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            controller.sendFile();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Select PDF'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: AppTextStyles.caption
                  .copyWith(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }

  // ─── Message options (long-press) ────────────────────────────────────────

  void _showMessageOptions(
      BuildContext context, MessageModel message, LearnController controller) {
    if (message.id.startsWith('temp_')) return;

    final auth = Get.find<AuthController>();
    final uid = controller.currentUserId;
    final role = auth.currentUser?['role'] as String? ?? 'student';
    final canPin = role == 'staff' || role == 'alumni' || role == 'admin';

    final room = controller.currentRoom;
    final pinned = controller.pinnedForRoom(room);
    final alreadyPinned =
        pinned.firstWhereOrNull((p) => p.messageId == message.id);
    final isPinner = alreadyPinned?.pinnedBy == uid;
    final canAddPin = canPin && alreadyPinned == null && pinned.length < 2;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
            // Reply
            ListTile(
              leading: const Icon(Icons.reply, color: AppColors.blue),
              title: const Text('Reply'),
              onTap: () {
                Navigator.pop(context);
                controller.setReplyTo(message);
              },
            ),
            // Delete own message
            if (message.isMe)
              ListTile(
                leading:
                    const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, message, controller);
                },
              ),
            // Pin (staff/alumni, not already pinned, room has < 2 pins)
            if (canAddPin)
              ListTile(
                leading: const Icon(Icons.push_pin_outlined,
                    color: Colors.amber),
                title: const Text('Pin Message'),
                onTap: () {
                  Navigator.pop(context);
                  _showPinDurationPicker(context, message, controller);
                },
              ),
            // Unpin (only by the person who pinned it)
            if (isPinner && alreadyPinned != null)
              ListTile(
                leading:
                    const Icon(Icons.push_pin, color: Colors.amber),
                title: const Text('Unpin Message'),
                onTap: () {
                  Navigator.pop(context);
                  controller.unpinMessage(alreadyPinned.id);
                  AppSnackbar.info('Unpinned', 'Message unpinned');
                },
              ),
            // Info when room is full and user could otherwise pin
            if (canPin && alreadyPinned == null && pinned.length >= 2)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Text(
                  'This room already has 2 pinned messages. Unpin one to add another.',
                  style: AppTextStyles.caption
                      .copyWith(color: Colors.grey[500], fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ─── Pin duration picker ─────────────────────────────────────────────────

  void _showPinDurationPicker(
      BuildContext context, MessageModel message, LearnController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Text(
                'Pin for how long?',
                style: AppTextStyles.subHeading.copyWith(
                    color: AppColors.blue, fontSize: 16),
              ),
            ),
            _buildDurationTile(
              context: context,
              icon: Icons.access_time,
              label: '24 hours',
              hours: 24,
              message: message,
              controller: controller,
            ),
            _buildDurationTile(
              context: context,
              icon: Icons.calendar_today,
              label: '7 days',
              hours: 24 * 7,
              message: message,
              controller: controller,
            ),
            _buildDurationTile(
              context: context,
              icon: Icons.event,
              label: '30 days',
              hours: 24 * 30,
              message: message,
              controller: controller,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int hours,
    required MessageModel message,
    required LearnController controller,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.blue),
      title: Text(label),
      onTap: () async {
        Navigator.pop(context);
        final success = await controller.pinMessage(message, hours);
        if (success) {
          AppSnackbar.success('Pinned', 'Message pinned for $label');
        } else {
          AppSnackbar.error(
            'Cannot Pin',
            'This chat room already has 2 pinned messages. Unpin one first.',
          );
        }
      },
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, MessageModel message, LearnController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Delete this message for everyone?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.deleteMessage(message.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ─── Open chat file/image in-app ─────────────────────────────────────────

  void _openChatFile(BuildContext context, MessageModel message) {
    final url = message.fileUrl;
    if (url == null) return;
    final name = message.fileName ?? 'file';
    final ext = name.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InAppImageViewer(imageUrl: url, title: name),
        ),
      );
    } else if (ext == 'pdf') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InAppPdfViewer(url: url, title: name),
        ),
      );
    } else {
      Get.snackbar(
        'Cannot Open',
        'This file type cannot be opened in-app. Try downloading it.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  String _formatTime(DateTime timestamp) {
    final hour =
        timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = timestamp.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
