import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/routes/app_routes.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/carousel_widget.dart';
import 'package:kc_connect/features/chat/controllers/learn_controller.dart';

class LearnPage extends StatelessWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LearnController controller = Get.put(LearnController());
    // Get.lazyPut(() => LearnController());

    return DefaultTabController(
      length: 2,
      child: Material(
        color: AppColors.backgroundColor,
        child: Column(
          children: [
            _buildCarouselBanner(),
            const SizedBox(height: 8),
            _buildTabBar(controller),
            Expanded(child: _buildTabBarView(controller)),
            _buildInputAreaWithAIButton(controller),
          ],
        ),
      ),
    );
  }

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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        color: AppColors.white.withOpacity(0.2),
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

  Widget _buildTabBarView(LearnController controller) {
    return Obx(() {
      if (controller.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      return IndexedStack(
        index: controller.currentTabIndex,
        children: [
          _buildChatView(controller, controller.grade10Messages),
          _buildChatView(controller, controller.grade12Messages),
        ],
      );
    });
  }

  Widget _buildChatView(LearnController controller, List messages) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppColors.blue.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to start the conversation!',
              style: AppTextStyles.caption.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageBubble(
          message.senderName,
          message.content,
          _formatTime(message.timestamp),
          message.isMe,
        );
      },
    );
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = timestamp.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Widget _buildMessageBubble(
    String sender,
    String message,
    String time,
    bool isMe,
  ) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: BoxConstraints(maxWidth: Get.width * 0.75),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 4),
                child: Text(
                  sender,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? AppColors.blue : AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
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
                          ? AppColors.white.withOpacity(0.8)
                          : Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputAreaWithAIButton(LearnController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: AppTextStyles.body.copyWith(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: AppColors.blue.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: AppColors.blue.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.blue),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (text) => controller.sendMessage(text),
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
              onPressed: () =>
                  controller.sendMessage(controller.messageController.text),
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
              icon: const Icon(
                Icons.auto_awesome,
                color: AppColors.white,
                size: 24,
              ),
              onPressed: () => Get.toNamed(AppRoutes.aiChat),
            ),
          ),
        ],
      ),
    );
  }
}
