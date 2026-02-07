// frontend/lib/services/location_monitor.dart

import 'dart:async';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../services/notification_service.dart';
import '../state/recommendation_state.dart';
import '../utils/config.dart';

class LocationMonitor {
  static Timer? _timer;
  static bool _isRunning = false;

  // Prevent repeated notifications for same nearest site
  static int? _lastNotifiedPrimarySiteId;

  // BACKGROUND PERIODIC MONITOR
  static void start() {
    if (_isRunning) return;
    _isRunning = true;

    _timer = Timer.periodic(const Duration(seconds: 20), (_) async {
      await _checkAndNotify();
    });
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _lastNotifiedPrimarySiteId = null;
  }

  // MANUAL ONE-TIME CHECK (PULL TO REFRESH)
  static Future<void> checkOnce() async {
    await _checkAndNotify(force: true);
  }

  // SHARED INTERNAL LOGIC
  static Future<void> _checkAndNotify({bool force = false}) async {
    try {
      // Permission & service check
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission =
          await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      // Position pos = await Geolocator.getCurrentPosition(
      //   desiredAccuracy: LocationAccuracy.high,
      // );

      // final res = await http.post(
      //   Uri.parse("$baseUrl/recommend-nearby"),
      //   headers: {"Content-Type": "application/json"},
      //   body: jsonEncode({
      //     "lat": pos.latitude,
      //     "lon": pos.longitude,
      //     "radius_m": 1500,
      //   }),
      // );

      // Fake GPS for testing
      final double lat = 7.2902;
      final double lon = 80.6337;

      final res = await http.post(
        Uri.parse("$baseUrl/recommend-nearby"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "lat": lat,
          "lon": lon,
          "radius_m": 1500,
        }),
      );

      if (res.statusCode != 200) return;

      final data = jsonDecode(res.body);
      if (data["recommended"] == null || data["recommended"].isEmpty) {
        return;
      }

      final List<dynamic> sites = data["recommended"];

      // Nearest site is always index 0 (already sorted by backend)
      final int primarySiteId = sites[0]["site_id"];

      // Prevent repeated notifications
      if (!force &&
          _lastNotifiedPrimarySiteId == primarySiteId) {
        return;
      }

      _lastNotifiedPrimarySiteId = primarySiteId;

      // Save ALL 3 recommendations globally
      RecommendationState.recommendedSites =
          List<Map<String, dynamic>>.from(sites);

      // Build clean notification message
      final String notificationBody =
          "You’re near ${sites[0]['site_name']}, "
          "${sites[1]['site_name']}, and "
          "${sites[2]['site_name']}. Tap to explore ancient events.";

      // Fire ONE aggregated notification
      await NotificationService.showNearbyNotification(
        "Nearby Heritage Sites",
        notificationBody,
      );
    } catch (_) {
      // intentionally silent to avoid background crashes
    }
  }
}
