import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AdminService {
  static const String baseUrl = 'http://192.168.1.100:5000/api';

  Future<Map<String, dynamic>> getMostAskedQuestions(
      BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final headers = authProvider.getHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/admin/reports/most-asked'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load most asked questions');
    }
  }

  Future<Map<String, dynamic>> getTestResultsSummary(
      BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final headers = authProvider.getHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/admin/reports/test-results'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load test results');
    }
  }

  Future<Map<String, dynamic>> getUserActivityReport(
      BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final headers = authProvider.getHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/admin/reports/user-activity'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user activity');
    }
  }
}