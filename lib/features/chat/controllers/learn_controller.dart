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
  final _replyingTo = Rxn<MessageModel>();

  // Text controllers
  final messageController = TextEditingController();

  // Supabase realtime channel
  RealtimeChannel? _channel;

  // Tab rooms
  final List<String> chatRooms = ['grade10', 'grade12'];

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
  MessageModel? get replyingTo => _replyingTo.value;

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

  // ─── Reply ─────────────────────────────────────────────────────────────────

  void setReplyTo(MessageModel message) => _replyingTo.value = message;
  void clearReply() => _replyingTo.value = null;

  // ─── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadMessages() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final currentUserId = Supabase.instance.client.auth.currentUser?.id;

      final data = await Supabase.instance.client
          .from('messages')
          .select(
            'id, content, room, sender_id, sender_name, created_at, '
            'message_type, file_url, file_name, file_size, '
            'reply_to_id, reply_to_content, reply_to_sender',
          )
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
      replyToId: row['reply_to_id'] as String?,
      replyToContent: row['reply_to_content'] as String?,
      replyToSenderName: row['reply_to_sender'] as String?,
    );
  }

  // ─── Realtime ──────────────────────────────────────────────────────────────

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

  // ─── Change tab ────────────────────────────────────────────────────────────

  void changeTab(int index) {
    if (index != _currentTabIndex.value) {
      _currentTabIndex.value = index;
      messageController.clear();
      clearReply();
    }
  }

  // ─── Send text message ─────────────────────────────────────────────────────

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

    // Capture reply before clearing
    final reply = _replyingTo.value;
    clearReply();

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
      replyToId: reply?.id,
      replyToContent: reply?.content.isNotEmpty == true
          ? reply!.content
          : (reply?.isImage == true ? '📷 Image' : reply != null ? '📎 File' : null),
      replyToSenderName: reply?.senderName,
    );

    if (room == 'grade10') {
      _grade10Messages.add(optimistic);
    } else {
      _grade12Messages.add(optimistic);
    }
    messageController.clear();

    try {
      final payload = {
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
        if (reply != null) 'reply_to_id': reply.id,
        if (reply != null)
          'reply_to_content': reply.content.isNotEmpty
              ? reply.content
              : (reply.isImage ? '📷 Image' : '📎 File'),
        if (reply != null) 'reply_to_sender': reply.senderName,
      };

      final result = await supabase
          .from('messages')
          .insert(payload)
          .select('id, created_at')
          .single();

      final sent = optimistic.copyWith(
        id: result['id'] as String,
        timestamp: DateTime.parse(result['created_at'] as String),
        status: MessageStatus.sent,
      );

      _replaceOptimistic(room, tempId, sent);
    } catch (e) {
      _replaceOptimistic(
          room, tempId, optimistic.copyWith(status: MessageStatus.failed));
      Get.snackbar('Error', 'Failed to send message',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));
    }
  }

  // ─── File / image sends ────────────────────────────────────────────────────

  Future<void> sendImageFromCamera() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 70);
    if (picked == null) return;
    final bytes = Uint8List.fromList(await picked.readAsBytes());
    await _uploadAndSendFile(
        bytes: bytes,
        fileName: picked.name,
        fileSize: bytes.length,
        messageType: 'image');
  }

  Future<void> sendImageFromGallery() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked == null) return;
    final bytes = Uint8List.fromList(await picked.readAsBytes());
    await _uploadAndSendFile(
        bytes: bytes,
        fileName: picked.name,
        fileSize: bytes.length,
        messageType: 'image');
  }

  Future<void> sendFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;
    await _uploadAndSendFile(
        bytes: Uint8List.fromList(file.bytes!),
        fileName: file.name,
        fileSize: file.size,
        messageType: 'file');
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
    final senderName =
        authController.currentUser?['full_name'] as String? ?? 'Unknown';
    final senderRole =
        authController.currentUser?['role'] as String? ?? 'student';

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
      final storagePath =
          '${currentUser.id}/${DateTime.now().millisecondsSinceEpoch}_$safeName';

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

      _replaceOptimistic(room, tempId, sent);
    } catch (e) {
      _replaceOptimistic(
          room, tempId, optimistic.copyWith(status: MessageStatus.failed));
      debugPrint('File upload error: $e');
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4));
    }
  }

  // ─── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteMessage(String messageId) async {
    final room = currentRoom;
    final list = room == 'grade10' ? _grade10Messages : _grade12Messages;
    final message = list.firstWhereOrNull((m) => m.id == messageId);

    if (message == null) return;
    if (!message.isMe) {
      Get.snackbar('Error', 'You can only delete your own messages',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));
      return;
    }

    try {
      await Supabase.instance.client.from('messages').update({
        'is_deleted': true,
        'deleted_at': DateTime.now().toIso8601String(),
      }).eq('id', messageId);

      if (room == 'grade10') {
        _grade10Messages.removeWhere((m) => m.id == messageId);
      } else {
        _grade12Messages.removeWhere((m) => m.id == messageId);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete message',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  void _replaceOptimistic(String room, String tempId, MessageModel replacement) {
    final list = room == 'grade10' ? _grade10Messages : _grade12Messages;
    final idx = list.indexWhere((m) => m.id == tempId);
    if (idx == -1) return;
    if (room == 'grade10') {
      _grade10Messages[idx] = replacement;
    } else {
      _grade12Messages[idx] = replacement;
    }
  }

  Future<void> refreshMessages() async => loadMessages();

  int getMessageCount(String room) =>
      room == 'grade10' ? _grade10Messages.length : _grade12Messages.length;

  MessageModel? getLastMessage(String room) {
    final messages = room == 'grade10' ? _grade10Messages : _grade12Messages;
    return messages.isEmpty ? null : messages.last;
  }
}
