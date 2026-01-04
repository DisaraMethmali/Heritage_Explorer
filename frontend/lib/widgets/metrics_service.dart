import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/metrics.dart';

class MetricsService {
  final String baseUrl = 'https://unvitrifiable-rhett-variedly.ngrok-free.dev';

  Future<Metrics> fetchMetrics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/metrics'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        return Metrics.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load metrics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching metrics: $e');
    }
  }
}