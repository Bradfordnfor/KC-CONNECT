// lib/features/chat/controllers/learn_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/models/message_model.dart';

class LearnController extends GetxController {
  // Reactive state
  final _grade10Messages = <MessageModel>[].obs;
  final _grade12Messages = <MessageModel>[].obs;
  final _currentTabIndex = 0.obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;

  // Text controllers
  final messageController = TextEditingController();

  // Tab rooms
  final List<String> chatRooms = ['grade10', 'grade12'];

  // Getters
  List<MessageModel> get grade10Messages => _grade10Messages;
  List<MessageModel> get grade12Messages => _grade12Messages;
  int get currentTabIndex => _currentTabIndex.value;
  String get currentRoom => chatRooms[_currentTabIndex.value];
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  List<MessageModel> get currentMessages {
    return _currentTabIndex.value == 0 ? _grade10Messages : _grade12Messages;
  }

  @override
  void onInit() {
    super.onInit();
    loadMessages();
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  // Load messages
  Future<void> loadMessages() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Load mock data (replace with Supabase real-time later)
      _grade10Messages.value = MessageModel.mockListForRoom('grade10');
      _grade12Messages.value = MessageModel.mockListForRoom('grade12');

      _isLoading.value = false;
    } catch (e) {
      _errorMessage.value = 'Failed to load messages: ${e.toString()}';
      _isLoading.value = false;
    }
  }

  // Change tab
  void changeTab(int index) {
    if (index != _currentTabIndex.value) {
      _currentTabIndex.value = index;
      messageController.clear();
    }
  }

  // Send message
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    try {
      final room = currentRoom;

      // Create new message
      final newMessage = MessageModel(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'current_user',
        senderName: 'You',
        content: content.trim(),
        timestamp: DateTime.now(),
        isMe: true,
        chatRoom: room,
        status: MessageStatus.sending,
      );

      // Add to appropriate room
      if (room == 'grade10') {
        _grade10Messages.add(newMessage);
      } else {
        _grade12Messages.add(newMessage);
      }

      // Clear input
      messageController.clear();

      // Simulate sending to server
      await Future.delayed(const Duration(milliseconds: 500));

      // Update message status to sent
      final index = currentMessages.indexWhere((m) => m.id == newMessage.id);
      if (index != -1) {
        if (room == 'grade10') {
          _grade10Messages[index] = newMessage.copyWith(
            status: MessageStatus.sent,
          );
        } else {
          _grade12Messages[index] = newMessage.copyWith(
            status: MessageStatus.sent,
          );
        }
      }

      // Simulate AI response for demo (optional)
      _simulateResponse(room, content);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send message',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Simulate a response from another user (for demo purposes)
  void _simulateResponse(String room, String userMessage) {
    // Only respond occasionally to keep it realistic
    if (DateTime.now().second % 3 != 0) return;

    Future.delayed(const Duration(seconds: 2), () {
      final responses = [
        'That\'s a great point!',
        'I agree with you on that.',
        'Can you explain more about that?',
        'Thanks for sharing!',
        'Interesting perspective.',
      ];

      final randomResponse =
          responses[DateTime.now().millisecond % responses.length];

      final responseMessage = MessageModel(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'other_user',
        senderName: room == 'grade10' ? 'Marie Ngono' : 'Bradford Toh',
        content: randomResponse,
        timestamp: DateTime.now(),
        isMe: false,
        chatRoom: room,
        status: MessageStatus.sent,
      );

      if (room == 'grade10') {
        _grade10Messages.add(responseMessage);
      } else {
        _grade12Messages.add(responseMessage);
      }
    });
  }

  // Delete message (only own messages)
  Future<void> deleteMessage(String messageId) async {
    try {
      final room = currentRoom;

      // Find message
      final messageList = room == 'grade10'
          ? _grade10Messages
          : _grade12Messages;
      final message = messageList.firstWhere((m) => m.id == messageId);

      // Check if it's user's message
      if (!message.isMe) {
        Get.snackbar(
          'Error',
          'You can only delete your own messages',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));

      // Remove message
      if (room == 'grade10') {
        _grade10Messages.removeWhere((m) => m.id == messageId);
      } else {
        _grade12Messages.removeWhere((m) => m.id == messageId);
      }

      Get.snackbar(
        'Deleted',
        'Message deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete message',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Refresh messages
  Future<void> refreshMessages() async {
    await loadMessages();
  }

  // Get message count for room
  int getMessageCount(String room) {
    return room == 'grade10'
        ? _grade10Messages.length
        : _grade12Messages.length;
  }

  // Get last message for room
  MessageModel? getLastMessage(String room) {
    final messages = room == 'grade10' ? _grade10Messages : _grade12Messages;
    return messages.isEmpty ? null : messages.last;
  }

  // Search messages in current room
  List<MessageModel> searchMessages(String query) {
    if (query.trim().isEmpty) return currentMessages;

    return currentMessages.where((m) {
      return m.content.toLowerCase().contains(query.toLowerCase()) ||
          m.senderName.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
