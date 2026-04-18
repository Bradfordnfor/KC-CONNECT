// lib/features/chat/controllers/ai_chat_controller.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kc_connect/features/auth/controllers/auth_controller.dart';
import 'package:kc_connect/features/payment/presentation/widgets/subscription_payment_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AiChatController extends GetxController {
  final messageController = TextEditingController();

  final _messages = <AiMessage>[].obs;
  final _isLoading = false.obs;
  final _isSending = false.obs;

  List<AiMessage> get messages => _messages;
  bool get isLoading => _isLoading.value;
  bool get isSending => _isSending.value;

  int get _userMessageCount => _messages.where((m) => m.isUser).length;

  String get userFirstName {
    final fullName = Get.find<AuthController>().currentUser?['full_name'] as String? ?? '';
    return fullName.split(' ').first;
  }

  final String _apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
  static const String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';

  final suggestedPrompts = [
    'Help me with Physics',
    'Explain Calculus',
    'Study tips',
    'Career advice',
    'Time management',
    'Exam preparation',
  ];

  String get _historyKey {
    final uid = Get.find<AuthController>().currentUser?['id'] as String? ?? 'guest';
    return 'ai_chat_history_$uid';
  }

  @override
  void onInit() {
    super.onInit();
    if (_apiKey.isEmpty || _apiKey == 'YOUR_GROQ_API_KEY_HERE') {
      debugPrint('⚠️ Groq API key missing in .env');
    }
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_historyKey);
      if (raw == null) return;
      final list = jsonDecode(raw) as List;
      _messages.value = list.map((e) => AiMessage.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('AI chat history load error: $e');
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Keep last 60 messages to avoid bloating storage
      final toSave = _messages.length > 60
          ? _messages.sublist(_messages.length - 60)
          : _messages.toList();
      await prefs.setString(_historyKey, jsonEncode(toSave.map((m) => m.toJson()).toList()));
    } catch (e) {
      debugPrint('AI chat history save error: $e');
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  // ─── Subscription gate ────────────────────────────────────────────────────

  bool _isGated() {
    final user = Get.find<AuthController>().currentUser;
    if (user == null) return false;
    final role = user['role'] as String? ?? '';
    if (role != 'student') return false;
    final status = user['subscription_status'] as String? ?? 'free';
    if (status == 'premium') {
      final endStr = user['subscription_end_date'] as String?;
      if (endStr != null) {
        final end = DateTime.tryParse(endStr);
        if (end != null && DateTime.now().isBefore(end)) return false;
      } else {
        return false;
      }
    }
    return _userMessageCount >= 1;
  }

  // ─── Send text message ────────────────────────────────────────────────────

  Future<void> sendMessage([String? customText]) async {
    final text = customText ?? messageController.text.trim();
    if (text.isEmpty) return;

    if (_isGated()) {
      Get.dialog(const SubscriptionPaymentModal(), barrierDismissible: false);
      return;
    }

    try {
      _isSending.value = true;

      _messages.add(AiMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      messageController.clear();

      final aiResponse = await _callGroq(text);
      _messages.add(AiMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _saveHistory();
    } catch (e) {
      _addError('Unable to get response. Check your connection.');
      debugPrint('AI sendMessage error: $e');
    } finally {
      _isSending.value = false;
    }
  }

  // ─── Groq API call ────────────────────────────────────────────────────────

  Future<String> _callGroq(String userMessage) async {
    if (_apiKey.isEmpty || _apiKey == 'YOUR_GROQ_API_KEY_HERE') {
      return '⚠️ AI is not configured yet.';
    }

    final history = _messages.length > 10
        ? _messages.sublist(_messages.length - 10)
        : List<AiMessage>.from(_messages);
    if (history.isNotEmpty && history.last.isUser && history.last.text == userMessage) {
      history.removeLast();
    }

    final body = jsonEncode({
      'model': _model,
      'messages': [
        {'role': 'system', 'content': _systemPrompt},
        ...history.map((msg) => {
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.text,
        }),
        {'role': 'user', 'content': userMessage},
      ],
      'temperature': 0.7,
      'max_tokens': 1024,
    });

    return _postWithRetry(body);
  }

  Future<String> _postWithRetry(String body) async {
    const maxAttempts = 3;
    const fallbackDelays = [5, 15, 30];

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await http.post(
          Uri.parse(_apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
          body: body,
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['choices']?[0]?['message']?['content'] ?? 'No response generated.';
        } else if (response.statusCode == 429) {
          debugPrint('Groq rate limit: ${response.body}');
          if (attempt >= maxAttempts) {
            return '⚠️ AI is busy right now. Please wait a moment and try again.';
          }
          final retryAfterSec = int.tryParse(response.headers['retry-after'] ?? '');
          final delay = retryAfterSec != null
              ? Duration(seconds: retryAfterSec.clamp(1, 60))
              : Duration(seconds: fallbackDelays[attempt - 1]);
          await Future.delayed(delay);
          continue;
        } else {
          debugPrint('Groq API error ${response.statusCode}: ${response.body}');
          return '⚠️ AI temporarily unavailable. Please try again.';
        }
      } on SocketException {
        if (attempt < maxAttempts) {
          await Future.delayed(Duration(seconds: fallbackDelays[attempt - 1]));
          continue;
        }
        return '⚠️ No internet connection. Please check your network.';
      } catch (e) {
        debugPrint('Groq request error: $e');
        if (attempt < maxAttempts) {
          await Future.delayed(Duration(seconds: fallbackDelays[attempt - 1]));
          continue;
        }
        return '⚠️ Network error. Please try again.';
      }
    }
    return '⚠️ AI is busy right now. Please try again in a moment.';
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _addError(String msg) {
    _messages.add(AiMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: '⚠️ $msg',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  static const String _systemPrompt = '''
You are KC Connect AI, the official learning companion on the KC Connect platform — built exclusively for students and alumni of Knowledge Center (KC) in Cameroon.

CONTEXT:
Knowledge Center is a secondary school in Cameroon following the Cameroon GCE Board curriculum.
- Form 4 and Form 5 students sit the GCE Ordinary Level (O/L) examinations.
- Lower Sixth and Upper Sixth students sit the GCE Advanced Level (A/L) examinations.
- Alumni are KC graduates now in university or the workforce.

O/L subjects include: Mathematics, English Language, French, Biology, Chemistry, Physics, Geography, History, Economics, Literature in English, Computer Science, Food and Nutrition, Agriculture, Religious Studies, Citizenship Education.

A/L subjects include: Mathematics, Further Mathematics, Physics, Chemistry, Biology, Economics, Geography, History, Literature in English, Computer Science, Geology, Philosophy, French, Accounting.

YOUR ROLE:
- Help students understand subject content, solve past paper questions, and prepare for exams.
- Explain topics at the right level: simpler and more concrete for O/L, deeper and more analytical for A/L.
- Guide alumni on university applications, career paths, scholarships, and professional development relevant to Cameroon and Africa.
- Offer study strategies, time management, and exam technique tailored to GCE Board style.
- When solving problems, always show working step by step so students learn the method, not just the answer.

IDENTITY:
If asked who you are, what you do, or anything about your purpose, respond naturally and warmly — for example: "I am KC Connect AI, your personal learning companion on KC Connect. I am here to help you study smarter, tackle tough topics, prepare for your exams, and grow beyond the classroom. What would you like to work on?" Adapt the wording naturally — do not copy it word for word every time.

RULES:
- Focus on education, academics, careers, and student life. If someone asks something completely unrelated (e.g. cooking, sports gossip, romance), redirect warmly in one sentence without being dismissive — something like "I am best at helping you study and grow. What would you like to explore?" Never mention internal terms like "GCE", "syllabus", or "curriculum" in refusals — keep it natural and human.
- Be direct and concise. Do not repeat the question or add unnecessary preamble.
- For a simple question, give 2 to 4 sentences. For a complex topic, use short labelled sections.
- Never use filler phrases like "Great question!", "Certainly!", "Of course!" or "Sure!".
- If you genuinely do not know something, say so honestly and suggest the student checks their textbook or asks their teacher.

FORMAT — follow strictly:
- Plain text only. No asterisks, no hash signs, no underscores, no markdown symbols whatsoever.
- For numbered steps or lists use "1. 2. 3." or "- " bullets only.
- Separate sections with a blank line and a plain label ending in a colon, e.g. "Key Points:" "Working:" "Example:" "Steps:" "Career Options:".
- Do not bold, italicise, or use any special characters for emphasis.
''';

  void sendSuggestedPrompt(String prompt) {
    messageController.text = prompt;
    sendMessage();
  }

  void clearChat() async {
    _messages.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
  };

  factory AiMessage.fromJson(Map<String, dynamic> j) => AiMessage(
    id: j['id'] as String,
    text: j['text'] as String,
    isUser: j['isUser'] as bool,
    timestamp: DateTime.parse(j['timestamp'] as String),
  );
}
