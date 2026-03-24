// lib/features/chat/controllers/ai_chat_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiChatController extends GetxController {
  final messageController = TextEditingController();

  final _messages = <AiMessage>[].obs;
  final _isLoading = false.obs;
  final _isSending = false.obs;

  List<AiMessage> get messages => _messages;
  bool get isLoading => _isLoading.value;
  bool get isSending => _isSending.value;

  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  final String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  final suggestedPrompts = [
    'Help me with Physics',
    'Explain Calculus',
    'Study tips',
    'Career advice',
    'Time management',
    'Exam preparation',
  ];

  @override
  void onInit() {
    super.onInit();
    if (_apiKey.isEmpty) {
      print('⚠️ Gemini API key missing in .env');
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  Future<void> sendMessage([String? customText]) async {
    final text = customText ?? messageController.text.trim();
    if (text.isEmpty) return;

    try {
      _isSending.value = true;

      // Add user message
      final userMessage = AiMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      );

      _messages.add(userMessage);
      messageController.clear();

      // Call AI
      final aiResponse = await _callGeminiApi(text);

      final aiMessage = AiMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      );

      _messages.add(aiMessage);

      _isSending.value = false;
    } catch (e) {
      _isSending.value = false;

      _messages.add(
        AiMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: '⚠️ Error: Unable to get response. Check your connection.',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );

      print('Error: $e');
    }
  }

  Future<String> _callGeminiApi(String userMessage) async {
    if (_apiKey.isEmpty) {
      return 'API key not configured.';
    }

    try {
      final systemPrompt = _buildSystemPrompt();

      // ✅ LIMIT HISTORY (last 10 messages)
      final recentMessages = _messages.length > 10
          ? _messages.sublist(_messages.length - 10)
          : _messages;

      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            // SYSTEM PROMPT
            {
              'role': 'user',
              'parts': [
                {'text': systemPrompt},
              ],
            },

            // CHAT HISTORY
            ...recentMessages.map(
              (msg) => {
                'role': msg.isUser ? 'user' : 'model',
                'parts': [
                  {'text': msg.text},
                ],
              },
            ),

            // CURRENT MESSAGE
            {
              'role': 'user',
              'parts': [
                {'text': userMessage},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
            'No response generated.';
      } else {
        print('API ERROR: ${response.body}');
        return '⚠️ API Error: ${response.statusCode}';
      }
    } catch (e) {
      print('Gemini Error: $e');
      return '⚠️ Network error. Please try again.';
    }
  }

  String _buildSystemPrompt() {
    return '''
You are KC Connect AI, an educational assistant.

RULES:
- Answer ONLY education, academics, career, or KC Connect topics
- Politely decline unrelated topics
- Understand intent even without keywords
- Maintain conversation context across messages

STYLE:
- Friendly, helpful, concise
- Use examples where helpful
- Ask follow-up questions when needed
''';
  }

  void sendSuggestedPrompt(String prompt) {
    messageController.text = prompt;
    sendMessage();
  }

  void clearChat() {
    _messages.clear();
  }

  int get messageCount => _messages.length;
}

class AiMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  AiMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
