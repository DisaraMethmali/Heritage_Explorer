// frontend/lib/state/recommendation_state.dart
// Global shared recommendation state
// Holds latest top-3 recommendations received from background notification

class RecommendationState {

  // List of recommended heritage sites (top 3)
  // Each item contains: site_id, site_name, distance_m, events[]
  static List<Map<String, dynamic>> recommendedSites = [];

  // Convenience getter
  static bool get hasRecommendation =>
      recommendedSites.isNotEmpty;

  // Clear all stored recommendations
  static void clear() {
    recommendedSites.clear();
  }
}
