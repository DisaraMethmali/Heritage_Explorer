import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class MemoryTestService {
  static const String baseUrl = 'http://192.168.1.100:5000/api';

  Future<Map<String, dynamic>> getQuestions(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final headers = authProvider.getHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/memory-test/questions'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load questions');
    }
  }

  Future<Map<String, dynamic>> submitTest(
    BuildContext context,
    Map<String, int> answers,
  ) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final headers = authProvider.getHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/memory-test/submit'),
      headers: headers,
      body: jsonEncode({'answers': answers}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to submit test');
    }
  }

  Future<Map<String, dynamic>> getTestHistory(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final headers = authProvider.getHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/memory-test/history'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load test history');
    }
  }
}