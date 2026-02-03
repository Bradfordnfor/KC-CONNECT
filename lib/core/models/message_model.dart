// lib/core/models/message_model.dart

class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderImageUrl;
  final String content;
  final DateTime timestamp;
  final bool isMe;
  final String chatRoom; // 'grade10', 'grade12', 'ai'
  final bool isAI;
  final MessageStatus status;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderImageUrl,
    required this.content,
    required this.timestamp,
    required this.isMe,
    required this.chatRoom,
    this.isAI = false,
    this.status = MessageStatus.sent,
  });

  // Getters for display
  String get displaySenderName => senderName;
  String get displayContent => content;
  String get formattedTime => _formatTime(timestamp);
  String get displayStatus => _getStatusText(status);

  // Format time
  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) {
      // Today - show time
      final hour = timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour;
      final minute = timestamp.minute.toString().padLeft(2, '0');
      final period = timestamp.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Yesterday
      return 'Yesterday';
    } else if (now.difference(timestamp).inDays < 7) {
      // Within a week - show day
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[timestamp.weekday - 1];
    } else {
      // Older - show date
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  // Get status text
  String _getStatusText(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return 'Sending...';
      case MessageStatus.sent:
        return 'Sent';
      case MessageStatus.delivered:
        return 'Delivered';
      case MessageStatus.read:
        return 'Read';
      case MessageStatus.failed:
        return 'Failed';
    }
  }

  // Copy with method
  MessageModel copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderImageUrl,
    String? content,
    DateTime? timestamp,
    bool? isMe,
    String? chatRoom,
    bool? isAI,
    MessageStatus? status,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderImageUrl: senderImageUrl ?? this.senderImageUrl,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isMe: isMe ?? this.isMe,
      chatRoom: chatRoom ?? this.chatRoom,
      isAI: isAI ?? this.isAI,
      status: status ?? this.status,
    );
  }

  // Mock data factory
  factory MessageModel.mock({
    String? id,
    String? senderName,
    String? content,
    bool? isMe,
    String? chatRoom,
    int? minutesAgo,
  }) {
    return MessageModel(
      id: id ?? 'msg_1',
      senderId: isMe == true
          ? 'current_user'
          : 'user_${DateTime.now().millisecond}',
      senderName: senderName ?? 'John Kamdem',
      senderImageUrl: 'assets/images/kc-connect_icon.png',
      content: content ?? 'Hey everyone! Anyone studying for the math test?',
      timestamp: DateTime.now().subtract(Duration(minutes: minutesAgo ?? 10)),
      isMe: isMe ?? false,
      chatRoom: chatRoom ?? 'grade10',
      status: MessageStatus.sent,
    );
  }

  // Create list of mock messages for a chat room
  static List<MessageModel> mockListForRoom(String room) {
    if (room == 'grade10') {
      return [
        MessageModel.mock(
          id: 'msg_g10_1',
          senderName: 'John Kamdem',
          content: 'Hey everyone! Anyone studying for the math test?',
          isMe: false,
          chatRoom: 'grade10',
          minutesAgo: 120,
        ),
        MessageModel.mock(
          id: 'msg_g10_2',
          senderName: 'You',
          content: 'Yes! I need help with quadratic equations',
          isMe: true,
          chatRoom: 'grade10',
          minutesAgo: 118,
        ),
        MessageModel.mock(
          id: 'msg_g10_3',
          senderName: 'Marie Ngono',
          content: 'I can help! What part are you struggling with?',
          isMe: false,
          chatRoom: 'grade10',
          minutesAgo: 115,
        ),
        MessageModel.mock(
          id: 'msg_g10_4',
          senderName: 'You',
          content: 'The discriminant formula. I keep getting confused.',
          isMe: true,
          chatRoom: 'grade10',
          minutesAgo: 110,
        ),
        MessageModel.mock(
          id: 'msg_g10_5',
          senderName: 'Marie Ngono',
          content:
              'b² - 4ac! Remember: if it\'s positive, you get 2 real roots.',
          isMe: false,
          chatRoom: 'grade10',
          minutesAgo: 108,
        ),
      ];
    } else if (room == 'grade12') {
      return [
        MessageModel.mock(
          id: 'msg_g12_1',
          senderName: 'Marie Ngono',
          content: 'Who is ready for the physics exam?',
          isMe: false,
          chatRoom: 'grade12',
          minutesAgo: 195,
        ),
        MessageModel.mock(
          id: 'msg_g12_2',
          senderName: 'Bradford Toh',
          content: 'I\'ve been studying all week! Electromagnetism is tough.',
          isMe: false,
          chatRoom: 'grade12',
          minutesAgo: 190,
        ),
        MessageModel.mock(
          id: 'msg_g12_3',
          senderName: 'You',
          content: 'Same here. Anyone have good notes on Maxwell\'s equations?',
          isMe: true,
          chatRoom: 'grade12',
          minutesAgo: 185,
        ),
      ];
    } else if (room == 'ai') {
      return [
        MessageModel.mock(
          id: 'msg_ai_1',
          senderName: 'You',
          content: 'Help me understand photosynthesis',
          isMe: true,
          chatRoom: 'ai',
          minutesAgo: 5,
        ),
        MessageModel(
          id: 'msg_ai_2',
          senderId: 'ai_assistant',
          senderName: 'KC Connect AI',
          content:
              'Photosynthesis is the process plants use to convert light energy into chemical energy. Here\'s a simple breakdown:\n\n1. Plants absorb sunlight through chlorophyll\n2. They take in CO₂ from the air and water from roots\n3. Light energy converts these into glucose (food) and oxygen\n4. The equation: 6CO₂ + 6H₂O + light → C₆H₁₂O₆ + 6O₂\n\nWould you like me to explain any specific part in more detail?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
          isMe: false,
          chatRoom: 'ai',
          isAI: true,
          status: MessageStatus.read,
        ),
      ];
    }

    return [];
  }

  // Get all messages (combining all rooms for demo)
  static List<MessageModel> mockAllMessages() {
    return [
      ...mockListForRoom('grade10'),
      ...mockListForRoom('grade12'),
      ...mockListForRoom('ai'),
    ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // For Supabase integration (future)
  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'sender_id': senderId,
  //     'sender_name': senderName,
  //     'sender_image_url': senderImageUrl,
  //     'content': content,
  //     'timestamp': timestamp.toIso8601String(),
  //     'is_me': isMe,
  //     'chat_room': chatRoom,
  //     'is_ai': isAI,
  //     'status': status.toString(),
  //   };
  // }

  // factory MessageModel.fromJson(Map<String, dynamic> json) {
  //   return MessageModel(
  //     id: json['id'] as String,
  //     senderId: json['sender_id'] as String,
  //     senderName: json['sender_name'] as String,
  //     senderImageUrl: json['sender_image_url'] as String?,
  //     content: json['content'] as String,
  //     timestamp: DateTime.parse(json['timestamp'] as String),
  //     isMe: json['is_me'] as bool,
  //     chatRoom: json['chat_room'] as String,
  //     isAI: json['is_ai'] as bool? ?? false,
  //     status: MessageStatus.values.firstWhere(
  //       (e) => e.toString() == json['status'],
  //       orElse: () => MessageStatus.sent,
  //     ),
  //   );
  // }
}

// Message status enum
enum MessageStatus { sending, sent, delivered, read, failed }
