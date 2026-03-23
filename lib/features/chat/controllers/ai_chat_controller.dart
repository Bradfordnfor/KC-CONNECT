// lib/features/chat/controllers/ai_chat_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiChatController extends GetxController {
  // Text controller
  final messageController = TextEditingController();

  // Observable state
  final _messages = <AiMessage>[].obs;
  final _isLoading = false.obs;
  final _isSending = false.obs;

  // Getters
  List<AiMessage> get messages => _messages;
  bool get isLoading => _isLoading.value;
  bool get isSending => _isSending.value;

  // Gemini API configuration
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  final String _apiUrl =
      'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent';

  // Suggested prompts
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
    _checkApiKey();
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  // Check if API key is configured
  void _checkApiKey() {
    if (_apiKey.isEmpty) {
      print('⚠️ WARNING: Gemini API key not found. Please add it to .env file');
    }
  }

  // Send message with Gemini API
  Future<void> sendMessage([String? customText]) async {
    final text = customText ?? messageController.text.trim();
    if (text.isEmpty) return;

    try {
      _isSending.value = true;

      // Add user message
      final userMessage = AiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      );
      _messages.add(userMessage);
      messageController.clear();

      // LAYER 1: Pre-filter - Check if topic is allowed
      final topic = _detectTopic(text);

      if (topic == 'off-topic') {
        // Don't call API, respond immediately
        final declineMessage = AiMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          text: _getOffTopicResponse(),
          isUser: false,
          timestamp: DateTime.now(),
        );
        _messages.add(declineMessage);
        _isSending.value = false;
        return;
      }

      // LAYER 2: Call Gemini API with system prompt
      final aiResponse = await _callGeminiApi(text);

      final aiMessage = AiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(aiMessage);

      _isSending.value = false;
    } catch (e) {
      _isSending.value = false;

      // Add error message
      final errorMessage = AiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Sorry, I encountered an error. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);

      print('Error sending message: $e');
      Get.snackbar(
        'Error',
        'Failed to get AI response. Check your internet connection.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
      );
    }
  }

  // Call Gemini API
  Future<String> _callGeminiApi(String userMessage) async {
    if (_apiKey.isEmpty) {
      return 'API key not configured. Please add GEMINI_API_KEY to your .env file.';
    }

    try {
      // Build system prompt with constraints
      final systemPrompt = _buildSystemPrompt();

      // Combine system prompt with user message
      final fullPrompt =
          '$systemPrompt\n\nUser Question: $userMessage\n\nAssistant:';

      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': fullPrompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract response text
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final candidate = data['candidates'][0];
          if (candidate['content'] != null &&
              candidate['content']['parts'] != null &&
              candidate['content']['parts'].isNotEmpty) {
            return candidate['content']['parts'][0]['text'] ??
                'No response generated.';
          }
        }

        return 'I apologize, but I couldn\'t generate a proper response. Please try rephrasing your question.';
      } else if (response.statusCode == 429) {
        return 'I\'m receiving too many requests right now. Please wait a moment and try again.';
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return 'Sorry, I encountered an error. Please try again.';
      }
    } catch (e) {
      print('Gemini API Error: $e');
      return 'Sorry, I couldn\'t connect to the AI service. Please check your internet connection.';
    }
  }

  // Build system prompt with education-only constraints
  String _buildSystemPrompt() {
    return '''You are KC Connect AI, an educational assistant for the KC Connect platform.

STRICT RULES - YOU MUST FOLLOW THESE:
1. ONLY answer questions about:
   - Education (subjects: Math, Physics, Chemistry, Biology, etc.)
   - Study techniques and exam preparation
   - Career guidance and skill development
   - KC Connect organization and platform features
   - Academic help and learning strategies

2. NEVER answer questions about:
   - Politics, religion, or controversial topics
   - Entertainment (movies, games, sports) unless related to education
   - Personal advice unrelated to education
   - Harmful, illegal, or inappropriate content
   - Any topic not related to education or KC Connect

3. If asked an off-topic question, politely decline and redirect to education.

ABOUT KC CONNECT:
- An alumni and student community platform
- Connects current students with alumni globally
- Features: Resources, Chat Rooms (Grade 10 & 12), Events, K-Store, AI Assistant
- Mission: Help KCians succeed academically and professionally

YOUR PERSONALITY:
- Friendly and encouraging
- Patient and supportive
- Clear and concise
- Focus on helping students learn and grow

RESPONSE FORMAT:
- Be conversational but professional
- Use examples when helpful
- Ask clarifying questions if needed
- Keep responses concise (2-3 paragraphs max)
- Use bullet points for lists''';
  }

  // Topic detection (Layer 1 filter)
  String _detectTopic(String message) {
    final lowerMessage = message.toLowerCase();

    // Check for education-related keywords
    if (_isEducationTopic(lowerMessage)) return 'education';

    // Check for organization-related keywords
    if (_isOrganizationTopic(lowerMessage)) return 'organization';

    // Everything else is off-topic
    return 'off-topic';
  }

  // Check if education-related
  bool _isEducationTopic(String message) {
    final educationKeywords = [
      // Subjects
      'math', 'physics', 'chemistry', 'biology', 'history', 'geography',
      'english', 'literature', 'calculus', 'algebra', 'geometry', 'science',
      'economics', 'computer', 'programming', 'coding', 'french', 'spanish',
      'trigonometry', 'statistics', 'mechanics', 'thermodynamics', 'organic',

      // Education activities
      'study', 'exam', 'test', 'homework', 'assignment', 'project', 'research',
      'learn', 'teach', 'grade', 'class', 'course', 'lesson', 'tutorial',
      'education', 'school', 'university', 'college', 'academic', 'syllabus',
      'revision', 'practice', 'quiz', 'exercise', 'problem', 'solution',

      // Skills & Career
      'career', 'skill', 'job', 'internship', 'scholarship', 'application',
      'cv',
      'resume',
      'interview',
      'university application',
      'college admission',

      // Study techniques
      'time management', 'productivity', 'focus', 'concentration', 'memory',
      'note-taking', 'revision', 'preparation', 'motivation', 'goal',

      // General learning
      'how to', 'explain', 'what is', 'why', 'help', 'understand', 'concept',
    ];

    return educationKeywords.any((keyword) => message.contains(keyword));
  }

  // Check if organization-related
  bool _isOrganizationTopic(String message) {
    final orgKeywords = [
      'kc connect',
      'kc',
      'konnect',
      'organization',
      'alumni',
      'community',
      'app',
      'platform',
      'feature',
      'how to use',
      'support',
      'about',
      'mission',
      'vision',
      'event',
      'resource',
      'store',
      'k-store',
      'grade 10',
      'grade 12',
      'student',
      'staff',
      'chat room',
      'learn page',
    ];

    return orgKeywords.any((keyword) => message.contains(keyword));
  }

  // Response for off-topic questions
  String _getOffTopicResponse() {
    return '👋 Hi! I appreciate your question, but I\'m specifically designed to help with:\n\n'
        '📚 **Education & Learning**\n'
        '• Subject help (Math, Physics, Chemistry, etc.)\n'
        '• Study techniques and exam preparation\n'
        '• Career guidance and skill development\n'
        '• Time management and productivity\n\n'
        '🏫 **KC Connect Organization**\n'
        '• Information about our platform\n'
        '• Features and how to use them\n'
        '• Alumni community and events\n\n'
        'How can I help you with your studies or our platform today? 📖';
  }

  // Send suggested prompt
  void sendSuggestedPrompt(String prompt) {
    messageController.text = prompt;
    sendMessage();
  }

  // Clear chat
  void clearChat() {
    _messages.clear();
  }

  // Get message count
  int get messageCount => _messages.length;
}

// AI Message model
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
