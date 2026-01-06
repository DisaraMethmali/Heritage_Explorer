// frontend/lib/screens/recommendation_screen.dart

import 'package:flutter/material.dart';
import '../state/recommendation_state.dart';
import '../services/location_monitor.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {

  // Pull-to-refresh handler
  Future<void> _onRefresh() async {
    await LocationMonitor.checkOnce();
    setState(() {}); // rebuild UI with updated recommendation
  }

  @override
  Widget build(BuildContext context) {
    final hasData = RecommendationState.hasRecommendation;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EC),

      appBar: AppBar(
        backgroundColor: const Color(0xFF004C7A),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
        title: const Text(
          "Recommended for You",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: hasData
              ? _buildRecommendationContent()
              : _buildEmptyState(),
        ),
      ),
    );
  }

  // EMPTY STATE (No recommendation)
  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.travel_explore,
                      size: 80,
                      color: Color(0xFF004C7A),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "No recommendations yet",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004C7A),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Pull to refresh or move closer to a heritage site to discover ancient events around you.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // MAIN CONTENT (TOP 3 SITES)
  Widget _buildRecommendationContent() {
    final sites = RecommendationState.recommendedSites;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: sites.map((site) {
          final List<Map<String, dynamic>> events =
              List<Map<String, dynamic>>.from(site["events"] ?? []);

          return Card(
            elevation: 8,
            margin: const EdgeInsets.only(bottom: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // SITE NAME
                  Text(
                    site["site_name"],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004C7A),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // DISTANCE
                  if (site["distance_m"] != null)
                    Text(
                      "Distance: ${(site["distance_m"] / 1000).toStringAsFixed(2)} km",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),

                  const SizedBox(height: 12),

                  // STATIC DESCRIPTION
                  const Text(
                    "A historically significant landmark rich in cultural and architectural heritage.",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // EVENTS HEADER
                  const Text(
                    "Ancient Events",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB8860B),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // EVENTS LIST
                  if (events.isEmpty)
                    const Text(
                      "No recorded events for this site.",
                      style: TextStyle(color: Colors.black54),
                    )
                  else
                    Column(
                      children: events.map((e) {
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                // EVENT TITLE
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.history_edu,
                                      color: Color(0xFF004C7A),
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        e["event_name"] ?? "Untitled Event",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF004C7A),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                if (e["year"] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      e["year"].toString(),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 8),

                                // EVENT DESCRIPTION
                                Text(
                                  e["description"] ??
                                      "No description available for this event.",
                                  textAlign: TextAlign.justify,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
