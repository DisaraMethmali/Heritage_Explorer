import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import 'recommended_topics_screen.dart';

// Import the new screens
import 'chat_history_screen.dart';
import 'test_history_screen.dart';
import 'preferences_screen.dart';
import 'test_results_screen.dart';
import 'memory_test_screen.dart'; // ✅ Memory Test

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  List<String>? _recommendations;
  bool _isLoading = true;

  // Define a default topic for recommendations
  final String topic = 'Recommended Topics';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      final profile = await apiService.getUserProfile();
      final recs = await apiService.getRecommendations();

      setState(() {
        _profile = profile;
        _recommendations =
            List<String>.from(recs['recommendations'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF004C7A),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ---------------- PROFILE CARD ----------------
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: const Color(0xFF004C7A),
                            child: Text(
                              _profile?['name']?.substring(0, 1) ?? 'U',
                              style: const TextStyle(
                                  fontSize: 32, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _profile?['name'] ?? 'User',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'User ID: ${_profile?['id'] ?? '--------'}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                

                  // ---------------- QUICK ACTIONS ----------------
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),

                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.chat_bubble_outline),
                          title: const Text('Chat History'),
                          subtitle: const Text('History saved → View anytime'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ChatHistoryScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.quiz_outlined),
                          title: const Text('Test History'),
                          subtitle: const Text('View all test attempts'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TestHistoryScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.bar_chart_outlined),
                          title: const Text('Test Results'),
                          subtitle: const Text('Detailed statistics'),
                          onTap: () {
                            // ✅ Pass dummy results for now
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TestResultsScreen(
                                  results: {
                                    'score': 85.0,
                                    'correct': 17,
                                    'total': 20,
                                    'results': [
                                      {
                                        'question':
                                            'What is the capital of Sri Lanka?',
                                        'explanation': 'The capital is Colombo.',
                                        'is_correct': true,
                                      },
                                      {
                                        'question': 'Who was the first king?',
                                        'explanation': 'The first king was Vijaya.',
                                        'is_correct': false,
                                      },
                                    ],
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.memory),
                          title: const Text('Memory Test'),
                          subtitle: const Text('Take a memory test now'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MemoryTestScreen(),
                              ),
                            );
                          },
                        ),
                         const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.recommend),
                          title: const Text('Recommended Topics'),
                          subtitle: const Text('Review recommended topics'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RecommendedTopicsScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.settings),
                          title: const Text('Preferences'),
                          subtitle: const Text('Set preferences'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PreferencesScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
