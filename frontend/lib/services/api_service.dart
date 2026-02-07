import 'dart:convert';
import 'package:http/http.dart' as http;

/// A cleaner, context-free API service
class ApiService {
  static const String baseUrl = 'http://192.168.8.100:5000/api';

  final Map<String, String> Function()? getHeaders;

  /// Optionally provide a function to get auth headers
  ApiService({this.getHeaders});
Future<void> sendFeedback(String feedback) async {
    await Future.delayed(const Duration(seconds: 1));
    print('Feedback sent: $feedback'); // Just a mock for demo
  }
  /// Send chat message
  Future<Map<String, dynamic>> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: getHeaders?.call() ?? {'Content-Type': 'application/json'},
        body: jsonEncode({'query': message}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      } else {
        throw Exception('Failed to send message: ${response.body}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  /// Submit feedback
  Future<Map<String, dynamic>> submitFeedback({
    required String query,
    required double rating,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/feedback'),
        headers: getHeaders?.call() ?? {'Content-Type': 'application/json'},
        body: jsonEncode({'query': query, 'rating': rating}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to submit feedback');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  /// Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: getHeaders?.call() ?? {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get profile');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  /// Get user recommendations
  Future<Map<String, dynamic>> getRecommendations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/recommendations'),
        headers: getHeaders?.call() ?? {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get recommendations');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  /// Get global stats
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stats'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      } else {
        throw Exception('Failed to get stats');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  /// Health check
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
