import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ⚠️ IMPORTANT: Replace with your actual ngrok URL
  static const String baseUrl = 'https://unvitrifiable-rhett-variedly.ngrok-free.dev';
  
  // Health Check
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/health'),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Health check failed: ${response.statusCode}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Send Chat Message
  // Send Chat Message
Future<Map<String, dynamic>> sendMessage({
  required String message,
  required String userId,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/chat'),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: json.encode({
        'query': message,  // must be 'query'
        'user_id': userId,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body) as Map<String, dynamic>;

      if (body['success'] == true && body['data'] != null) {
        // Return the full data map, including answer, confidence, etc.
        return body;
      } else {
        throw Exception('Server returned no data');
      }
    } else {
      throw Exception('Failed to send message: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Message error: $e');
  }
}


  Future<Map<String, dynamic>> sendFeedback({
  required String userId,
  required String messageId,
  required int rating,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/feedback'),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: json.encode({
        'user_id': userId,
        'message_id': messageId,
        'rating': rating,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);

      // Extract the data field
      final Map<String, dynamic> data =
          Map<String, dynamic>.from(body['data'] ?? {});

      return {
        'message': data['message'] ?? '',
        'epsilon': data['epsilon'],
        'reward': data['reward'],
        'success': data['success'] ?? false,
      };
    }
    throw Exception('Failed to send feedback: ${response.statusCode}');
  } catch (e) {
    throw Exception('Feedback error: $e');
  }
}

  
  // Get User Profile
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/profile/$userId'),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to get profile');
    } catch (e) {
      throw Exception('Profile error: $e');
    }
  }
  
  // Get Recommendations
  Future<Map<String, dynamic>> getRecommendations(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/recommendations'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: json.encode({'user_id': userId}),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to get recommendations');
    } catch (e) {
      throw Exception('Recommendations error: $e');
    }
  }
  
  // Get Chat History
  Future<Map<String, dynamic>> getChatHistory(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/history/$userId'),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to get history');
    } catch (e) {
      throw Exception('History error: $e');
    }
  }
  
  // Get Metrics
  Future<Map<String, dynamic>> getMetrics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/metrics'),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to get metrics');
    } catch (e) {
      throw Exception('Metrics error: $e');
    }
  }
  
  // Get Stats
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/stats'),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to get stats');
    } catch (e) {
      throw Exception('Stats error: $e');
    }
  }
}