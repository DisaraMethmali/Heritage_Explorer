import 'package:flutter/material.dart';
import '../services/memory_test_service.dart';
import 'package:intl/intl.dart';

class TestHistoryScreen extends StatefulWidget {
  const TestHistoryScreen({super.key});

  @override
  State<TestHistoryScreen> createState() => _TestHistoryScreenState();
}

class _TestHistoryScreenState extends State<TestHistoryScreen> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    try {
      final service = MemoryTestService();
      final result = await service.getTestHistory(context);

      setState(() {
        _data = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? const Center(child: Text('No test history'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Statistics card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(
                                'Your Statistics',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const Divider(height: 32),
                              _buildStatRow(
                                'Total Tests',
                                _data!['statistics']['total_tests'].toString(),
                              ),
                              _buildStatRow(
                                'Average Score',
                                '${_data!['statistics']['average_score'].toStringAsFixed(1)}%',
                              ),
                              _buildStatRow(
                                'Best Score',
                                '${_data!['statistics']['best_score'].toStringAsFixed(1)}%',
                              ),
                              _buildStatRow(
                                'Latest Score',
                                '${_data!['statistics']['latest_score'].toStringAsFixed(1)}%',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Test History',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      ...(_data!['history'] as List).map((test) {
                        final timestamp = DateTime.parse(test['timestamp']);
                        final score = test['score'] as double;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: score >= 70
                                  ? Colors.green
                                  : score >= 50
                                      ? Colors.orange
                                      : Colors.red,
                              child: Text(
                                '${score.toInt()}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              '${test['correct']}/${test['total']} correct',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              DateFormat('MMM dd, yyyy - hh:mm a')
                                  .format(timestamp),
                            ),
                            trailing: Icon(
                              score >= 70
                                  ? Icons.emoji_events
                                  : Icons.trending_up,
                              color: score >= 70
                                  ? Colors.amber
                                  : Colors.grey,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}