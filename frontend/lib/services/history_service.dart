import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HistoryService {
  static const String baseUrl = 'http://192.168.1.6:5000/api';

  Future<Map<String, dynamic>> getChatHistory(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final headers = authProvider.getHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/chat/history'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load chat history');
    }
  }

  Future<Map<String, dynamic>> getPreferences(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final headers = authProvider.getHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/user/preferences'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load preferences');
    }
  }

  Future<void> updatePreferences(
    BuildContext context,
    Map<String, dynamic> preferences,
  ) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final headers = authProvider.getHeaders();

    final response = await http.put(
      Uri.parse('$baseUrl/user/preferences'),
      headers: headers,
      body: jsonEncode(preferences),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update preferences');
    }
  }
}