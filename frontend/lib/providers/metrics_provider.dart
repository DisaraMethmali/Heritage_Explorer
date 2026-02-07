import 'package:flutter/material.dart';
import '../models/metrics.dart';
import '../services/metrics_service.dart';

class MetricsProvider extends ChangeNotifier {
  Metrics? metrics;
  bool isLoading = false;
  String? error;

  final MetricsService _service = MetricsService();

  Future<void> loadMetrics() async {
    isLoading = true;
    notifyListeners();

    try {
      metrics = await _service.fetchMetrics();
      error = null;
    } catch (e) {
      error = e.toString();
      metrics = null;
    }

    isLoading = false;
    notifyListeners();
  }
}
