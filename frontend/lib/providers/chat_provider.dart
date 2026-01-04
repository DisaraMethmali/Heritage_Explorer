import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  final ApiService apiService;

  ChatProvider({required this.apiService});

  final List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    _error = null;

    addMessage(Message(
      id: const Uuid().v4(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    _isLoading = true;
    notifyListeners();

    try {
      final data = await apiService.sendMessage(text);

      addMessage(Message(
        id: const Uuid().v4(),
        text: data['answer'] ?? 'No response',
        isUser: false,
        timestamp: DateTime.now(),
      ));
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

  Future<void> sendFeedback(String feedback) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      await apiService.sendFeedback(feedback);

      addMessage(Message(
        id: const Uuid().v4(),
        text: 'Feedback sent successfully!',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      _error = e.toString();
      addMessage(Message(
        id: const Uuid().v4(),
        text: 'Error sending feedback: $e',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
