// frontend/lib/state/recommendation_state.dart (Create global shared recommendation state, 
//                                                holds latest recommendatin from notification)

class RecommendationState {
  static int? siteId;
  static String? siteName;
  static List<Map<String, dynamic>> events = []; 

  static bool get hasRecommendation =>
      siteId != null && events.isNotEmpty;

  static void clear() {
    siteId = null;
    siteName = null;
    events.clear();
  }
}
