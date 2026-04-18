// lib/features/chat/controllers/learn_controller.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kc_connect/core/models/message_model.dart';
import 'package:kc_connect/core/controllers/navigation_controller.dart';
import 'package:kc_connect/features/auth/controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─── Pinned message model ──────────────────────────────────────────────────

class PinnedChatMessage {
  final String id;
  final String messageId;
  final String room; // 'grade_10' or 'grade_12'
  final String pinnedBy;
  final String pinnerName;
  final DateTime pinnedUntil;
  final String messageContent;
  final String messageSenderName;
  final DateTime createdAt;

  PinnedChatMessage({
    required this.id,
    required this.messageId,
    required this.room,
    required this.pinnedBy,
    required this.pinnerName,
    required this.pinnedUntil,
    required this.messageContent,
    required this.messageSenderName,
    required this.createdAt,
  });

  String get timeRemainingLabel {
    final diff = pinnedUntil.difference(DateTime.now());
    if (diff.inDays >= 1) return '${diff.inDays}d left';
    if (diff.inHours >= 1) return '${diff.inHours}h left';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m left';
    return 'Expiring';
  }

  factory PinnedChatMessage.fromRow(Map<String, dynamic> row) {
    return PinnedChatMessage(
      id: row['id'] as String,
      messageId: row['message_id'] as String,
      room: row['room'] as String,
      pinnedBy: row['pinned_by'] as String,
      pinnerName: row['pinner_name'] as String? ?? '',
      pinnedUntil: DateTime.parse(row['pinned_until'] as String),
      messageContent: row['message_content'] as String? ?? '',
      messageSenderName: row['message_sender_name'] as String? ?? '',
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}

// ─── Controller ────────────────────────────────────────────────────────────

class LearnController extends GetxController {
  // Reactive state
  final _grade10Messages = <MessageModel>[].obs;
  final _grade12Messages = <MessageModel>[].obs;
  final _grade10Pinned = <PinnedChatMessage>[].obs;
  final _grade12Pinned = <PinnedChatMessage>[].obs;
  final _currentTabIndex = 0.obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final _replyingTo = Rxn<MessageModel>();

  // Unread message counts (per room)
  final _unreadGrade10 = 0.obs;
  final _unreadGrade12 = 0.obs;

  // Text controllers
  final messageController = TextEditingController();

  // Scroll controllers for each chat room
  final grade10ScrollController = ScrollController();
  final grade12ScrollController = ScrollController();

  // GlobalKeys for accurate scroll-to-message
  final Map<String, GlobalKey> messageKeys = {};

  GlobalKey keyForMessage(String messageId) {
    return messageKeys.putIfAbsent(messageId, () => GlobalKey());
  }

  ScrollController scrollControllerForRoom(String room) =>
      room == 'grade10' ? grade10ScrollController : grade12ScrollController;

  // Supabase realtime channel
  RealtimeChannel? _channel;

  // Tab rooms
  final List<String> chatRooms = ['grade10', 'grade12'];

  String _toDbRoom(String room) => room == 'grade10' ? 'grade_10' : 'grade_12';
  String _fromDbRoom(String dbRoom) =>
      dbRoom == 'grade_10' ? 'grade10' : 'grade12';

  // Getters — messages
  List<MessageModel> get grade10Messages => _grade10Messages.toList();
  List<MessageModel> get grade12Messages => _grade12Messages.toList();
  int get currentTabIndex => _currentTabIndex.value;
  String get currentRoom => chatRooms[_currentTabIndex.value];
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  MessageModel? get replyingTo => _replyingTo.value;
  String? get currentUserId => Supabase.instance.client.auth.currentUser?.id;

  List<MessageModel> get currentMessages =>
      _currentTabIndex.value == 0 ? _grade10Messages : _grade12Messages;

  // Getters — pinned
  List<PinnedChatMessage> get grade10Pinned => _grade10Pinned.toList();
  List<PinnedChatMessage> get grade12Pinned => _grade12Pinned.toList();
  List<PinnedChatMessage> get currentPinned =>
      _currentTabIndex.value == 0 ? _grade10Pinned : _grade12Pinned;

  List<PinnedChatMessage> pinnedForRoom(String room) =>
      room == 'grade10' ? _grade10Pinned.toList() : _grade12Pinned.toList();

  // ─── Access & unread ──────────────────────────────────────────────────────

  /// True when the current user may send messages in [room].
  /// Students are limited to the room matching their class level.
  /// Staff, alumni, and admin can send in both rooms.
  bool canSendInRoom(String room) {
    final user = Get.find<AuthController>().currentUser;
    final role = user?['role'] as String? ?? '';
    if (role != 'student') return true; // alumni / staff / admin → both rooms

    // DB level takes precedence. Fall back to Supabase auth user_metadata when
    // the DB row has an empty level — this happens when the handle_new_user
    // trigger does not copy the level field from user_metadata.
    var level = user?['level'] as String? ?? '';
    if (level.isEmpty) {
      level = Supabase.instance.client.auth.currentUser
              ?.userMetadata?['level'] as String? ?? '';
    }

    if (room == 'grade10') return level == 'form_4' || level == 'form_5';
    if (room == 'grade12') return level == 'lower_sixth' || level == 'upper_sixth';
    return false;
  }

  bool get canSendInCurrentRoom => canSendInRoom(currentRoom);

  /// Total unread count for rooms the user can send in.
  /// Reading .value inside Obx makes this reactive.
  int get unreadCount {
    final user = Get.find<AuthController>().currentUser;
    final role = user?['role'] as String? ?? '';
    if (role != 'student') return _unreadGrade10.value + _unreadGrade12.value;
    var level = user?['level'] as String? ?? '';
    if (level.isEmpty) {
      level = Supabase.instance.client.auth.currentUser
              ?.userMetadata?['level'] as String? ?? '';
    }
    if (level == 'form_4' || level == 'form_5') return _unreadGrade10.value;
    if (level == 'lower_sixth' || level == 'upper_sixth') return _unreadGrade12.value;
    return 0;
  }

  bool _isLearnTabActive() {
    try {
      return Get.find<NavigationController>().currentIndex == 2;
    } catch (_) {
      return false;
    }
  }

  // ─── Load unread counts from DB ───────────────────────────────────────────

  Future<void> _loadUnreadCounts() async {
    final userId = currentUserId;
    if (userId == null) return;
    try {
      final row = await Supabase.instance.client
          .from('users')
          .select('chat_grade10_read_at, chat_grade12_read_at')
          .eq('id', userId)
          .single();

      final g10ReadAt = row['chat_grade10_read_at'] as String?;
      final g12ReadAt = row['chat_grade12_read_at'] as String?;

      if (canSendInRoom('grade10')) {
        if (g10ReadAt != null) {
          final result = await Supabase.instance.client
              .from('messages')
              .select('id')
              .eq('room', 'grade_10')
              .eq('is_deleted', false)
              .neq('sender_id', userId)
              .gt('created_at', g10ReadAt);
          _unreadGrade10.value = (result as List).length;
        }
        // If null → first visit, leave at 0; markCurrentRoomAsRead sets it.
      }

      if (canSendInRoom('grade12')) {
        if (g12ReadAt != null) {
          final result = await Supabase.instance.client
              .from('messages')
              .select('id')
              .eq('room', 'grade_12')
              .eq('is_deleted', false)
              .neq('sender_id', userId)
              .gt('created_at', g12ReadAt);
          _unreadGrade12.value = (result as List).length;
        }
      }
    } catch (e) {
      debugPrint('Load unread counts error: $e');
    }
  }

  // ─── Mark room as read ────────────────────────────────────────────────────

  /// Call when the user actively opens the Learn tab or switches sub-tabs.
  Future<void> markCurrentRoomAsRead() async {
    final userId = currentUserId;
    if (userId == null) return;
    final room = currentRoom; // 'grade10' or 'grade12'
    final column =
        room == 'grade10' ? 'chat_grade10_read_at' : 'chat_grade12_read_at';
    try {
      await Supabase.instance.client
          .from('users')
          .update({column: DateTime.now().toIso8601String()})
          .eq('id', userId);
      if (room == 'grade10') {
        _unreadGrade10.value = 0;
      } else {
        _unreadGrade12.value = 0;
      }
    } catch (e) {
      debugPrint('Mark room as read error: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadMessages();
    loadPinnedMessages();
    _loadUnreadCounts();
    _subscribeToRealtime();
  }

  @override
  void onClose() {
    _channel?.unsubscribe();
    grade10ScrollController.dispose();
    grade12ScrollController.dispose();
    super.onClose();
  }

  /// Scrolls to the message matching [messageId] regardless of direction.
  /// Uses [RenderAbstractViewport.getOffsetToReveal] for pixel-perfect accuracy.
  void scrollToMessage(String messageId, String room) {
    final key = messageKeys[messageId];
    if (key == null || key.currentContext == null) return;
    final sc = scrollControllerForRoom(room);
    if (!sc.hasClients) return;

    final renderObject = key.currentContext!.findRenderObject();
    if (renderObject == null) return;

    final viewport = RenderAbstractViewport.of(renderObject);
    // alignment 0.2 places the message near the top of the viewport
    final revealOffset =
        viewport.getOffsetToReveal(renderObject, 0.2).offset;
    final target =
        revealOffset.clamp(0.0, sc.position.maxScrollExtent);

    sc.animateTo(
      target,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  // ─── Reply ─────────────────────────────────────────────────────────────────

  void setReplyTo(MessageModel message) => _replyingTo.value = message;
  void clearReply() => _replyingTo.value = null;

  // ─── Load messages ─────────────────────────────────────────────────────────

  Future<void> loadMessages() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final uid = currentUserId;

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
        final msg = _fromRow(row, uid);
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

  MessageModel _fromRow(Map<String, dynamic> row, String? uid) {
    final senderId = row['sender_id'] as String? ?? '';
    return MessageModel(
      id: row['id'] as String,
      senderId: senderId,
      senderName: row['sender_name'] as String? ?? 'Unknown',
      content: row['content'] as String? ?? '',
      timestamp: DateTime.parse(row['created_at'] as String),
      isMe: senderId == uid,
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

  // ─── Load pinned messages ──────────────────────────────────────────────────

  Future<void> loadPinnedMessages() async {
    try {
      final now = DateTime.now().toIso8601String();
      final data = await Supabase.instance.client
          .from('pinned_messages')
          .select()
          .inFilter('room', ['grade_10', 'grade_12'])
          .gt('pinned_until', now)
          .order('created_at', ascending: true);

      final g10 = <PinnedChatMessage>[];
      final g12 = <PinnedChatMessage>[];
      for (final row in data) {
        final p = PinnedChatMessage.fromRow(row);
        if (row['room'] == 'grade_10') {
          g10.add(p);
        } else {
          g12.add(p);
        }
      }
      _grade10Pinned.value = g10;
      _grade12Pinned.value = g12;
    } catch (e) {
      debugPrint('Load pinned messages error: $e');
    }
  }

  // ─── Pin / unpin ───────────────────────────────────────────────────────────

  /// Returns true on success, false if the room already has 2 pins.
  Future<bool> pinMessage(MessageModel message, int hours) async {
    final room = currentRoom;
    final dbRoom = _toDbRoom(room);
    final pinned = pinnedForRoom(room);

    if (pinned.length >= 2) return false;

    final uid = currentUserId;
    if (uid == null) return false;

    final auth = Get.find<AuthController>();
    final pinnerName =
        auth.currentUser?['full_name'] as String? ?? 'Unknown';

    try {
      final pinnedUntil =
          DateTime.now().add(Duration(hours: hours)).toIso8601String();
      final content = message.content.isNotEmpty
          ? message.content
          : message.isImage
              ? '📷 Image'
              : '📎 File';

      final result = await Supabase.instance.client
          .from('pinned_messages')
          .insert({
            'message_id': message.id,
            'room': dbRoom,
            'pinned_by': uid,
            'pinner_name': pinnerName,
            'pinned_until': pinnedUntil,
            'message_content': content,
            'message_sender_name': message.senderName,
          })
          .select()
          .single();

      final newPin = PinnedChatMessage.fromRow(result);
      if (room == 'grade10') {
        _grade10Pinned.add(newPin);
      } else {
        _grade12Pinned.add(newPin);
      }
      return true;
    } catch (e) {
      debugPrint('Pin message error: $e');
      return false;
    }
  }

  Future<void> unpinMessage(String pinnedId) async {
    try {
      await Supabase.instance.client
          .from('pinned_messages')
          .delete()
          .eq('id', pinnedId);

      _grade10Pinned.removeWhere((p) => p.id == pinnedId);
      _grade12Pinned.removeWhere((p) => p.id == pinnedId);
    } catch (e) {
      debugPrint('Unpin message error: $e');
      Get.snackbar('Error', 'Failed to unpin message',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));
    }
  }

  // ─── Realtime ──────────────────────────────────────────────────────────────

  void _subscribeToRealtime() {
    final uid = currentUserId;

    _channel = Supabase.instance.client
        .channel('learn_realtime')
        // New messages
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

            final msg = _fromRow(row, uid);
            final room = _fromDbRoom(dbRoom);
            final list =
                room == 'grade10' ? _grade10Messages : _grade12Messages;
            if (list.any((m) => m.id == msg.id)) return;
            if (room == 'grade10') {
              _grade10Messages.add(msg);
            } else {
              _grade12Messages.add(msg);
            }

            // Increment unread if user is not currently viewing this room
            final isViewingThisRoom =
                _isLearnTabActive() && currentRoom == room;
            if (!isViewingThisRoom && msg.senderId != uid && canSendInRoom(room)) {
              if (room == 'grade10') {
                _unreadGrade10.value++;
              } else {
                _unreadGrade12.value++;
              }
            }
          },
        )
        // New pin
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'pinned_messages',
          callback: (payload) {
            final row = payload.newRecord;
            final p = PinnedChatMessage.fromRow(row);
            // Avoid duplicates (our own insert already updates the list)
            final list = row['room'] == 'grade_10'
                ? _grade10Pinned
                : _grade12Pinned;
            if (!list.any((x) => x.id == p.id)) {
              if (row['room'] == 'grade_10') {
                _grade10Pinned.add(p);
              } else {
                _grade12Pinned.add(p);
              }
            }
          },
        )
        // Deleted pin
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'pinned_messages',
          callback: (payload) {
            final id = payload.oldRecord['id'] as String?;
            if (id == null) return;
            _grade10Pinned.removeWhere((p) => p.id == id);
            _grade12Pinned.removeWhere((p) => p.id == id);
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
      markCurrentRoomAsRead();
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
    final auth = Get.find<AuthController>();
    final senderName =
        auth.currentUser?['full_name'] as String? ?? 'Unknown';
    final senderRole =
        auth.currentUser?['role'] as String? ?? 'student';

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
          : (reply?.isImage == true
              ? '📷 Image'
              : reply != null
                  ? '📎 File'
                  : null),
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

      _replaceOptimistic(
          room,
          tempId,
          optimistic.copyWith(
            id: result['id'] as String,
            timestamp: DateTime.parse(result['created_at'] as String),
            status: MessageStatus.sent,
          ));
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
    final auth = Get.find<AuthController>();
    final senderName =
        auth.currentUser?['full_name'] as String? ?? 'Unknown';
    final senderRole =
        auth.currentUser?['role'] as String? ?? 'student';

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

      final result = await supabase
          .from('messages')
          .insert({
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
          })
          .select('id, created_at')
          .single();

      _replaceOptimistic(
          room,
          tempId,
          optimistic.copyWith(
            id: result['id'] as String,
            timestamp: DateTime.parse(result['created_at'] as String),
            status: MessageStatus.sent,
            fileUrl: fileUrl,
          ));
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

  void _replaceOptimistic(
      String room, String tempId, MessageModel replacement) {
    final list =
        room == 'grade10' ? _grade10Messages : _grade12Messages;
    final idx = list.indexWhere((m) => m.id == tempId);
    if (idx == -1) return;
    if (room == 'grade10') {
      _grade10Messages[idx] = replacement;
    } else {
      _grade12Messages[idx] = replacement;
    }
  }

  Future<void> refreshMessages() async {
    await loadMessages();
    await loadPinnedMessages();
  }

  int getMessageCount(String room) =>
      room == 'grade10' ? _grade10Messages.length : _grade12Messages.length;

  MessageModel? getLastMessage(String room) {
    final messages =
        room == 'grade10' ? _grade10Messages : _grade12Messages;
    return messages.isEmpty ? null : messages.last;
  }
}
