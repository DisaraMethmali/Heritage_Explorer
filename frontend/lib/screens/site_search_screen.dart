// frontend/lib/screens/site_search_screen

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../state/user_location_state.dart';
import '../utils/config.dart';
import 'map_route_screen.dart';

class SiteSearchScreen extends StatefulWidget {
  const SiteSearchScreen({super.key});

  @override
  State<SiteSearchScreen> createState() => _SiteSearchScreenState();
}

class _SiteSearchScreenState extends State<SiteSearchScreen> {

  final TextEditingController _searchController = TextEditingController();

  bool isLoading = false;
  List<Map<String, dynamic>> results = [];

  // SEARCH FUNCTION
  Future<void> _searchSite(String name) async {

    if (name.trim().isEmpty) return;

    setState(() => isLoading = true);

    try {

      final res = await http.post(
        Uri.parse("$baseUrl/search-site"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "site_name": name.trim(),
          "user_lat": UserLocationState.userLat,
          "user_lon": UserLocationState.userLon,
        }),
      );

      if (!mounted) return;

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        results = List<Map<String, dynamic>>.from(data["results"] ?? []);
      } else {
        results.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Heritage site not found."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Network error. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => isLoading = false);
  }

  // SEARCH BAR 
  Widget _buildSearchBar() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Icon(Icons.search, color: Color(0xFF004C7A)),
            const SizedBox(width: 8),

            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  textSelectionTheme: const TextSelectionThemeData(
                    cursorColor: Color(0xFF004C7A),
                    selectionHandleColor: Color(0xFF004C7A),
                    selectionColor: Color(0xFF81D4FA),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: "Search site (Eg: Galle Fort)",
                    hintStyle: TextStyle(fontSize: 15),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) {
                    _searchSite(value.trim());
                  },
                ),
              ),
            ),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [

                GestureDetector(
                  onTap: () {
                    _searchSite(_searchController.text.trim());
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 20,
                      color: Color(0xFF004C7A),
                    ),
                  ),
                ),

                const SizedBox(width: 4),

                GestureDetector(
                  onTap: () {
                    setState(() {
                      _searchController.clear();
                      results.clear();
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: Color(0xFF004C7A),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // EMPTY STATE (same design style)
  Widget _buildStyledEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 120,
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
                      "Search for a Heritage Site",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004C7A),
                      ),
                    ),

                    SizedBox(height: 12),

                    Text(
                      "Enter the name of a heritage site to view its location weather safety information historical events and navigation route.",
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

  // SAFETY BADGE
  Widget _buildSafetyBadge(String status) {

    Color bgColor;
    Color textColor;

    switch (status) {
      case "SAFE":
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;

      case "CAUTION":
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;

      case "UNSAFE":
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;

      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  // Shortens long address AND removes PLUS CODES if present
  String _shortPlace(String address) {
    List<String> parts = address.split(",");

    if (parts.isEmpty) return address;

    // If first part contains Google Plus Code
    if (parts[0].contains("+")) {
      if (parts.length >= 3) {
        return "${parts[1].trim()}, ${parts[2].trim()}";
      } else if (parts.length >= 2) {
        return parts[1].trim();
      }
      return address;
    }

    // Normal case: first two segments only
    if (parts.length >= 2) {
      return "${parts[0].trim()}, ${parts[1].trim()}";
    }

    return parts[0].trim();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // UI BUILD
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EC),

      appBar: AppBar(
        backgroundColor: const Color(0xFF004C7A),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
        title: const Text(
          "Search Heritage Site",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Column(
        children: [

          const SizedBox(height: 16),

          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSearchBar(),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF004C7A),
                    ),
                  )
                : results.isEmpty
                    ? _buildStyledEmptyState()
                    : ListView.builder(

                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: results.length,
                        itemBuilder: (_, index) {

                          final site = results[index];
                          final events = List<Map<String, dynamic>>.from(site["events"] ?? []);

                          return Card(

                            elevation: 8,
                            margin: const EdgeInsets.only(bottom: 20),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),

                            child: Padding(
                              padding: const EdgeInsets.all(16),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  // SITE NAME
                                  Text(
                                    site["site_name"],
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF004C7A),
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  // ADDRESS
                                  if (site["place_name"] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              _shortPlace(site["place_name"]),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  const SizedBox(height: 6),

                                  // SAFETY BADGE
                                  if (site["safety_status"] != null)
                                    _buildSafetyBadge(site["safety_status"]),

                                  const SizedBox(height: 10),

                                  // DISTANCE
                                  if (site["distance_km"] != null)
                                    Text(
                                      "Distance from you: ${site["distance_km"]} km",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),

                                  const SizedBox(height: 12),

                                  // WEATHER
                                  if (site["weather"] != null)
                                    Row(
                                      children: [

                                        if (site["weather"]["icon"] != null)
                                          Image.network(
                                            "https:${site["weather"]["icon"]}",
                                            width: 40,
                                            height: 40,
                                          ),

                                        const SizedBox(width: 8),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [

                                              Text(
                                                site["weather"]["condition"] ?? "",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),

                                              Text(
                                                "${site["weather"]["temperature_c"] ?? "--"}°C • "
                                                "Humidity ${site["weather"]["humidity"] ?? "--"}% • "
                                                "Wind ${site["weather"]["wind_kph"] ?? "--"} km/h",
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                  const SizedBox(height: 10),

                                  // DISASTER ALERT
                                  if (site["disaster"] != null)
                                    Row(
                                      children: [

                                        Icon(
                                          site["disaster"]["has_alert"] == true
                                              ? Icons.warning
                                              : Icons.check_circle,
                                          color: site["disaster"]["has_alert"] == true
                                              ? (site["disaster"]["risk_level"] == "High"
                                                  ? Colors.red
                                                  : Colors.orange)
                                              : Colors.green,
                                        ),

                                        const SizedBox(width: 8),

                                        Expanded(
                                          child: Text(
                                            site["disaster"]["has_alert"] == true
                                                ? (site["disaster"]["message"] ??
                                                    "Weather Alert")
                                                : "No active disaster alerts",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: site["disaster"]["has_alert"] == true
                                                  ? (site["disaster"]["risk_level"] ==
                                                          "High"
                                                      ? Colors.red.shade800
                                                      : Colors.orange.shade800)
                                                  : Colors.green.shade800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                  const SizedBox(height: 16),

                                  // EVENTS HEADER
                                  const Text(
                                    "Ancient Events",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFB8860B),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  if (events.isEmpty)
                                    const Text(
                                      "No recorded events.",
                                      style: TextStyle(
                                        color: Colors.black54,
                                      ),
                                    )
                                  else
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: events.map((e) {

                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 12),

                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [

                                              Text(
                                                e["year"] != null
                                                    ? "${e["event_name"]} (${e["year"]})"
                                                    : e["event_name"] ??
                                                        "Untitled Event",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),

                                              const SizedBox(height: 4),

                                              Text(
                                                e["description"] ?? "",
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  height: 1.4,
                                                  color: Colors.black87,
                                                ),
                                                textAlign: TextAlign.justify,
                                              ),
                                            ],
                                          ),
                                        );

                                      }).toList(),
                                    ),

                                  const SizedBox(height: 16),

                                  // MAP ROUTE BUTTON
                                  Center(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.directions),
                                      label: const Text("View Route"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF004C7A),
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () {

                                        if (UserLocationState.userLat == null ||
                                            UserLocationState.userLon == null) {

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "User location not available."),
                                            ),
                                          );

                                          return;
                                        }

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => MapRouteScreen(
                                              userLat: UserLocationState.userLat!,
                                              userLon: UserLocationState.userLon!,
                                              destLat: site["lat"],
                                              destLon: site["lon"],
                                              siteName: site["site_name"],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}