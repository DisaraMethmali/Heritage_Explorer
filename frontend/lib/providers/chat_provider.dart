import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService;
  final List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  ChatProvider({required ApiService apiService}) : _apiService = apiService;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  /// ---------------- SEND MESSAGE ----------------
  Future<void> sendMessage(String text, String userId) async {
  _error = null;

  // Add user message locally
  final userMessage = Message(
    id: const Uuid().v4(),
    text: text,
    isUser: true,
    timestamp: DateTime.now(),
  );
  addMessage(userMessage);

  _isLoading = true;
  notifyListeners();

  try {
    final response = await http.post(
      Uri.parse('https://unvitrifiable-rhett-variedly.ngrok-free.dev/api/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "query": text,
        "user_id": userId,
      }),
    );

    debugPrint("📥 Response status: ${response.statusCode}");
    debugPrint("📥 Response body: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      // Extract the actual bot data
    final Map<String, dynamic> decoded = jsonDecode(response.body);

// Extract 'data' safely
final Map<String, dynamic> data = Map<String, dynamic>.from(decoded['data'] ?? {});

final botMessage = Message(
  id: decoded['message_id']?.toString() ?? const Uuid().v4(),
  text: data['answer']?.toString() ?? 'No response',
  isUser: false,
  timestamp: DateTime.now(),
  confidence: (data['confidence'] as num?)?.toDouble(),
  responseTime: (data['retrieval_time'] as num?)?.toDouble(),
);

      addMessage(botMessage);
    } else {
      throw Exception("Failed to send message: ${response.statusCode}");
    }
  } catch (e) {
    _error = e.toString();
    addMessage(Message(
      id: const Uuid().v4(),
      text: 'Error: $e',
      isUser: false,
      timestamp: DateTime.now(),
      isError: true,
    ));
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  /// ---------------- SEND FEEDBACK ----------------
  Future<void> sendFeedback(String messageId, int rating, String userId) async {
    debugPrint("📤 Sending feedback...");
    debugPrint("messageId=$messageId, rating=$rating, userId=$userId");

    try {
      final Message botMessage = _messages.firstWhere((m) => m.id == messageId);

      final response = await http.post(
        Uri.parse('https://unvitrifiable-rhett-variedly.ngrok-free.dev/api/feedback'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "query": botMessage.text,
          "rating": rating,
          "user_id": userId,
        }),
      );

      debugPrint("📥 Feedback status: ${response.statusCode}");
      debugPrint("📥 Feedback body: ${response.body}");

      if (response.statusCode == 200) {
        final index = _messages.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          _messages[index] = _messages[index].copyWith(rating: rating);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("❌ Feedback error: $e");
    }
  }
}
