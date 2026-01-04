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
                      "Move closer to a heritage site to discover ancient events around you.",
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

  // MAIN CONTENT (With data)
  Widget _buildRecommendationContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // SITE HEADER CARD (IMAGE REMOVED)
          Card(
            elevation: 8,
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
                    RecommendationState.siteName!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004C7A),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // STATIC DESCRIPTION
                  const Text(
                    "A historically significant landmark rich in cultural and architectural heritage.",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // EVENTS HEADER
          const Text(
            "Ancient Events",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB8860B),
            ),
          ),

          const SizedBox(height: 16),

          // EVENTS LIST
          Column(
            children: RecommendationState.events.map((e) {
              return Card(
                elevation: 5,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // EVENT TITLE
                      Row(
                        children: [
                          const Icon(Icons.history_edu,
                              color: Color(0xFF004C7A), size: 26),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              e["event_name"] ?? "Untitled Event",
                              style: const TextStyle(
                                fontSize: 17,
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
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.black54,
                            ),
                          ),
                        ),

                      const SizedBox(height: 10),

                      // EVENT DESCRIPTION
                      Text(
                        e["description"] ??
                            "No description available for this event.",
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          fontSize: 15,
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
    );
  }
}
