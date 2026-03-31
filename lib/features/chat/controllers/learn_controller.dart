// lib/features/chat/controllers/learn_controller.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kc_connect/core/models/message_model.dart';
import 'package:kc_connect/features/auth/controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LearnController extends GetxController {
  // Reactive state
  final _grade10Messages = <MessageModel>[].obs;
  final _grade12Messages = <MessageModel>[].obs;
  final _currentTabIndex = 0.obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;

  // Text controllers
  final messageController = TextEditingController();

  // Supabase realtime channel
  RealtimeChannel? _channel;

  // Tab rooms (internal names match tab labels)
  final List<String> chatRooms = ['grade10', 'grade12'];

  // Map controller room name ↔ DB room value
  String _toDbRoom(String room) => room == 'grade10' ? 'grade_10' : 'grade_12';
  String _fromDbRoom(String dbRoom) =>
      dbRoom == 'grade_10' ? 'grade10' : 'grade12';

  // Getters
  List<MessageModel> get grade10Messages => _grade10Messages.toList();
  List<MessageModel> get grade12Messages => _grade12Messages.toList();
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
    _subscribeToMessages();
  }

  @override
  void onClose() {
    messageController.dispose();
    _channel?.unsubscribe();
    super.onClose();
  }

  // Load messages from Supabase
  Future<void> loadMessages() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final currentUserId = Supabase.instance.client.auth.currentUser?.id;

      final data = await Supabase.instance.client
          .from('messages')
          .select('id, content, room, sender_id, sender_name, created_at, message_type, file_url, file_name, file_size')
          .inFilter('room', ['grade_10', 'grade_12'])
          .eq('is_deleted', false)
          .order('created_at', ascending: true)
          .limit(100);

      final grade10 = <MessageModel>[];
      final grade12 = <MessageModel>[];

      for (final row in data) {
        final msg = _fromRow(row, currentUserId);
        if (row['room'] == 'grade_10') {
          grade10.add(msg);
        } else {
          grade12.add(msg);
        }
      }

      _grade10Messages.value = grade10;
      _grade12Messages.value = grade12;
      _isLoading.value = false;
    } catch (e) {
      _errorMessage.value = 'Failed to load messages: ${e.toString()}';
      _isLoading.value = false;
    }
  }

  MessageModel _fromRow(Map<String, dynamic> row, String? currentUserId) {
    final senderId = row['sender_id'] as String? ?? '';
    return MessageModel(
      id: row['id'] as String,
      senderId: senderId,
      senderName: row['sender_name'] as String? ?? 'Unknown',
      content: row['content'] as String? ?? '',
      timestamp: DateTime.parse(row['created_at'] as String),
      isMe: senderId == currentUserId,
      chatRoom: _fromDbRoom(row['room'] as String? ?? 'grade_10'),
      status: MessageStatus.sent,
      messageType: row['message_type'] as String? ?? 'text',
      fileUrl: row['file_url'] as String?,
      fileName: row['file_name'] as String?,
      fileSize: row['file_size'] as int?,
    );
  }

  void _subscribeToMessages() {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    _channel = Supabase.instance.client
        .channel('messages_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            final row = payload.newRecord;
            final dbRoom = row['room'] as String?;
            if (dbRoom == null) return;
            if (dbRoom != 'grade_10' && dbRoom != 'grade_12') return;
            if (row['is_deleted'] == true) return;

            final msg = _fromRow(row, currentUserId);
            // Skip if it's our own optimistic message that was already added
            final room = _fromDbRoom(dbRoom);
            final list = room == 'grade10' ? _grade10Messages : _grade12Messages;
            if (list.any((m) => m.id == msg.id)) return;

            if (room == 'grade10') {
              _grade10Messages.add(msg);
            } else {
              _grade12Messages.add(msg);
            }
          },
        )
        .subscribe();
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

    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return;

    final room = currentRoom;
    final dbRoom = _toDbRoom(room);
    final authController = Get.find<AuthController>();
    final senderName =
        authController.currentUser?['full_name'] as String? ?? 'Unknown';
    final senderRole =
        authController.currentUser?['role'] as String? ?? 'student';

    // Optimistic add
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimistic = MessageModel(
      id: tempId,
      senderId: currentUser.id,
      senderName: senderName,
      content: content.trim(),
      timestamp: DateTime.now(),
      isMe: true,
      chatRoom: room,
      status: MessageStatus.sending,
    );

    if (room == 'grade10') {
      _grade10Messages.add(optimistic);
    } else {
      _grade12Messages.add(optimistic);
    }
    messageController.clear();

    try {
      final result = await supabase.from('messages').insert({
        'content': content.trim(),
        'room': dbRoom,
        'sender_id': currentUser.id,
        'sender_name': senderName,
        'sender_role': senderRole,
        'is_deleted': false,
        'is_edited': false,
        'is_flagged': false,
        'is_pinned': false,
        'message_type': 'text',
      }).select('id, created_at').single();

      final sent = optimistic.copyWith(
        id: result['id'] as String,
        timestamp: DateTime.parse(result['created_at'] as String),
        status: MessageStatus.sent,
      );

      final list = room == 'grade10' ? _grade10Messages : _grade12Messages;
      final idx = list.indexWhere((m) => m.id == tempId);
      if (idx != -1) {
        if (room == 'grade10') {
          _grade10Messages[idx] = sent;
        } else {
          _grade12Messages[idx] = sent;
        }
      }
    } catch (e) {
      final list = room == 'grade10' ? _grade10Messages : _grade12Messages;
      final idx = list.indexWhere((m) => m.id == tempId);
      if (idx != -1) {
        final failed = optimistic.copyWith(status: MessageStatus.failed);
        if (room == 'grade10') {
          _grade10Messages[idx] = failed;
        } else {
          _grade12Messages[idx] = failed;
        }
      }
      Get.snackbar(
        'Error',
        'Failed to send message',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Pick image from camera and send
  Future<void> sendImageFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (picked == null) return;
    final bytes = Uint8List.fromList(await picked.readAsBytes());
    await _uploadAndSendFile(
      bytes: bytes,
      fileName: picked.name,
      fileSize: bytes.length,
      messageType: 'image',
    );
  }

  // Pick image from gallery and send
  Future<void> sendImageFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked == null) return;
    final bytes = Uint8List.fromList(await picked.readAsBytes());
    await _uploadAndSendFile(
      bytes: bytes,
      fileName: picked.name,
      fileSize: bytes.length,
      messageType: 'image',
    );
  }

  // Pick a file (PDF, doc, etc.) and send
  Future<void> sendFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;
    await _uploadAndSendFile(
      bytes: Uint8List.fromList(file.bytes!),
      fileName: file.name,
      fileSize: file.size,
      messageType: 'file',
    );
  }

  Future<void> _uploadAndSendFile({
    required Uint8List bytes,
    required String fileName,
    required int fileSize,
    required String messageType,
  }) async {
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return;

    final room = currentRoom;
    final dbRoom = _toDbRoom(room);
    final authController = Get.find<AuthController>();
    final senderName = authController.currentUser?['full_name'] as String? ?? 'Unknown';
    final senderRole = authController.currentUser?['role'] as String? ?? 'student';

    // Optimistic placeholder
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimistic = MessageModel(
      id: tempId,
      senderId: currentUser.id,
      senderName: senderName,
      content: '',
      timestamp: DateTime.now(),
      isMe: true,
      chatRoom: room,
      status: MessageStatus.sending,
      messageType: messageType,
      fileName: fileName,
      fileSize: fileSize,
    );
    if (room == 'grade10') {
      _grade10Messages.add(optimistic);
    } else {
      _grade12Messages.add(optimistic);
    }

    try {
      final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final storagePath = '${currentUser.id}/${DateTime.now().millisecondsSinceEpoch}_$safeName';

      await supabase.storage
          .from('chat-attachments')
          .uploadBinary(storagePath, bytes);

      final fileUrl = supabase.storage
          .from('chat-attachments')
          .getPublicUrl(storagePath);

      final result = await supabase.from('messages').insert({
        'content': '',
        'room': dbRoom,
        'sender_id': currentUser.id,
        'sender_name': senderName,
        'sender_role': senderRole,
        'is_deleted': false,
        'is_edited': false,
        'is_flagged': false,
        'is_pinned': false,
        'message_type': messageType,
        'file_url': fileUrl,
        'file_name': fileName,
        'file_size': fileSize,
      }).select('id, created_at').single();

      final sent = optimistic.copyWith(
        id: result['id'] as String,
        timestamp: DateTime.parse(result['created_at'] as String),
        status: MessageStatus.sent,
        fileUrl: fileUrl,
      );

      final list = room == 'grade10' ? _grade10Messages : _grade12Messages;
      final idx = list.indexWhere((m) => m.id == tempId);
      if (idx != -1) {
        if (room == 'grade10') {
          _grade10Messages[idx] = sent;
        } else {
          _grade12Messages[idx] = sent;
        }
      }
    } catch (e) {
      final list = room == 'grade10' ? _grade10Messages : _grade12Messages;
      final idx = list.indexWhere((m) => m.id == tempId);
      if (idx != -1) {
        if (room == 'grade10') {
          _grade10Messages[idx] = optimistic.copyWith(status: MessageStatus.failed);
        } else {
          _grade12Messages[idx] = optimistic.copyWith(status: MessageStatus.failed);
        }
      }
      Get.snackbar('Error', 'Failed to send file',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));
    }
  }

  // Delete message (soft-delete in DB)
  Future<void> deleteMessage(String messageId) async {
    try {
      final room = currentRoom;
      final messageList =
          room == 'grade10' ? _grade10Messages : _grade12Messages;
      final message = messageList.firstWhere((m) => m.id == messageId);

      if (!message.isMe) {
        Get.snackbar(
          'Error',
          'You can only delete your own messages',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      await Supabase.instance.client.from('messages').update({
        'is_deleted': true,
        'deleted_at': DateTime.now().toIso8601String(),
      }).eq('id', messageId);

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
