// frontend/lib/screens/area_search_result_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../state/user_location_state.dart';
import '../utils/config.dart';
import 'map_route_screen.dart';

class AreaSearchResultScreen extends StatefulWidget {
  const AreaSearchResultScreen({super.key});

  @override
  State<AreaSearchResultScreen> createState() =>
      _AreaSearchResultScreenState();
}

class _AreaSearchResultScreenState
    extends State<AreaSearchResultScreen> {

  final TextEditingController _searchController =
      TextEditingController();

  bool isLoading = false;
  String? searchedArea;
  List<Map<String, dynamic>> results = [];

  // FETCH RESULTS
  Future<void> _fetchAreaResults(String area) async {

    if (area.isEmpty) return;

    setState(() {
      isLoading = true;
      searchedArea = area;
    });

    final res = await http.post(
      Uri.parse("$baseUrl/search-area"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "area": area,
        "user_lat": UserLocationState.userLat,
        "user_lon": UserLocationState.userLon,
      }),
    );

    if (!mounted) return;

    final data = jsonDecode(res.body);

    if (res.statusCode == 200) {
      results = List<Map<String, dynamic>>.from(data["results"] ?? []);
    }

    // AREA NOT FOUND
    else if (res.statusCode == 404) {

      results.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Area not found. Please check the spelling and try again.",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }

    // OTHER SERVER ERRORS
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => isLoading = false);
  }

  // Search Bar
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
                    cursorColor: Color(0xFF004C7A), // blinking cursor
                    selectionHandleColor: Color(0xFF004C7A), // drop icon color
                    selectionColor: Color(0xFF81D4FA), // text highlight color
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: "Search area (Eg: Matara, Galle...)",
                    hintStyle: TextStyle(
                      fontSize: 15, 
                    ),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) {
                    _fetchAreaResults(value.trim());
                  },
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    _fetchAreaResults(_searchController.text.trim());
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
                      searchedArea = null;
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
            )
          ],
        ),
      ),
    );
  }

  // Empty State
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
                      "Search for a Heritage Area",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004C7A),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Enter an area name above to explore nearby heritage sites with events, weather updates, safety status, and route information.",
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
  // String _shortPlace(String address) {
  //   List<String> parts = address.split(",");

  //   if (parts.isEmpty) return address;

  //   // If first part contains Google Plus Code
  //   if (parts[0].contains("+")) {
  //     if (parts.length >= 3) {
  //       return "${parts[1].trim()}, ${parts[2].trim()}";
  //     } else if (parts.length >= 2) {
  //       return parts[1].trim();
  //     }
  //     return address;
  //   }

  //   // Normal case: first two segments only
  //   if (parts.length >= 2) {
  //     return "${parts[0].trim()}, ${parts[1].trim()}";
  //   }

  //   return parts[0].trim();
  // }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // BUILD
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
          "Search Heritage by Area",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [

            const SizedBox(height: 16),

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
                            final events =
                                List<Map<String, dynamic>>.from(
                                    site["events"] ?? []);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 20),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    Text(
                                      site["site_name"],
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF004C7A),
                                      ),
                                    ),

                                    // if (site["place_name"] != null)
                                    //   Padding(
                                    //     padding: const EdgeInsets.only(top: 4),
                                    //     child: Text(
                                    //       site["place_name"],
                                    //       style: const TextStyle(
                                    //         fontSize: 13,
                                    //         color: Colors.black54,
                                    //       ),
                                    //     ),
                                    //   ),

                                    // if (site["place_name"] != null)
                                    //   Padding(
                                    //     padding: const EdgeInsets.only(top: 4),
                                    //     child: Row(
                                    //       children: [
                                    //         const Icon(
                                    //           Icons.location_on,
                                    //           size: 16,
                                    //           color: Colors.grey,
                                    //         ),
                                    //         const SizedBox(width: 4),
                                    //         Expanded(
                                    //           child: Text(
                                    //             _shortPlace(site["place_name"]),
                                    //             style: const TextStyle(
                                    //               fontSize: 13,
                                    //               color: Colors.black54,
                                    //             ),
                                    //           ),
                                    //         ),
                                    //       ],
                                    //     ),
                                    //   ),

                                    const SizedBox(height: 6),

                                    _buildSafetyBadge(site["safety_status"] ??""),

                                    const SizedBox(height: 10),

                                    if (searchedArea != null)
                                      Text(
                                        "Distance from $searchedArea: "
                                        "${site["distance_from_area_km"]} km",
                                      ),

                                    Text(
                                      "Distance from you: "
                                      "${site["distance_from_user_km"]} km",
                                    ),

                                    const SizedBox(height: 12),

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
                                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                                    ? (site["disaster"]["risk_level"] == "High"
                                                        ? Colors.red.shade800
                                                        : Colors.orange.shade800)
                                                    : Colors.green.shade800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                    const SizedBox(height: 14),

                                    if (events.isNotEmpty)
                                      ...events.map((e) =>
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [

                                                // Event Name + Year
                                                Text(
                                                  e["year"] != null
                                                      ? "${e["event_name"]} (${e["year"]})"
                                                      : e["event_name"] ?? "Untitled Event",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),

                                                const SizedBox(height: 4),

                                                // Description
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
                                          )),

                                    const SizedBox(height: 14),

                                    Center(
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.directions),
                                        label: const Text("View Route"),
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Color(0xFF004C7A), // text + icon color
                                          side: const BorderSide(
                                            color: Color(0xFF004C7A), // border color same as button
                                            width: 2,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: () {
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
      ),
    );
  }
}