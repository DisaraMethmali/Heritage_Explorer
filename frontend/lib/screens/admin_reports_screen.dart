// lib/screens/admin_reports_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/admin_service.dart';
import 'package:intl/intl.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  Map<String, dynamic>? _mostAskedData;
  Map<String, dynamic>? _testResultsData;
  Map<String, dynamic>? _userActivityData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllReports() async {
    setState(() => _isLoading = true);

    try {
      final service = AdminService();

      final mostAsked = await service.getMostAskedQuestions(context);
      final testResults = await service.getTestResultsSummary(context);
      final userActivity = await service.getUserActivityReport(context);

      setState(() {
        _mostAskedData = mostAsked;
        _testResultsData = testResults;
        _userActivityData = userActivity;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reports: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Reports'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Most Asked', icon: Icon(Icons.question_answer)),
            Tab(text: 'Test Results', icon: Icon(Icons.assessment)),
            Tab(text: 'User Activity', icon: Icon(Icons.people)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllReports,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMostAskedTab(),
                _buildTestResultsTab(),
                _buildUserActivityTab(),
              ],
            ),
    );
  }

  Widget _buildMostAskedTab() {
    if (_mostAskedData == null) {
      return const Center(child: Text('No data available'));
    }

    final questions = _mostAskedData!['most_asked'] as List;

    return RefreshIndicator(
      onRefresh: _loadAllReports,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Total Unique Questions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_mostAskedData!['total_unique_questions']}',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Top 20 Most Asked Questions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;

            return Card(
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: index < 3
                      ? Colors.amber
                      : Theme.of(context).colorScheme.primary,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  question['question'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Chip(
                  label: Text('${question['count']} times'),
                  backgroundColor: Colors.blue.shade50,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTestResultsTab() {
    if (_testResultsData == null) {
      return const Center(child: Text('No data available'));
    }

    final summary = _testResultsData!['test_summary'] as List;

    return RefreshIndicator(
      onRefresh: _loadAllReports,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Users Who Took Tests',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_testResultsData!['total_users_tested']}',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'User Test Performance',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...summary.map((user) {
            final avgScore = user['average_score'] as double;
            final bestScore = user['best_score'] as double;

            return Card(
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: avgScore >= 70
                      ? Colors.green
                      : avgScore >= 50
                          ? Colors.orange
                          : Colors.red,
                  child: Text(
                    user['user_name'][0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(user['user_name']),
                subtitle: Text(user['user_email']),
                trailing: Text(
                  '${avgScore.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildStatRow('Total Tests', '${user['total_tests']}'),
                        _buildStatRow('Average Score', '${avgScore.toStringAsFixed(1)}%'),
                        _buildStatRow('Best Score', '${bestScore.toStringAsFixed(1)}%'),
                        _buildStatRow('Latest Score', '${user['latest_score'].toStringAsFixed(1)}%'),
                        const Divider(),
                        Text(
                          'Last Test: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(user['latest_test_date']))}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildUserActivityTab() {
    if (_userActivityData == null) {
      return const Center(child: Text('No data available'));
    }

    final activity = _userActivityData!['user_activity'] as List;

    return RefreshIndicator(
      onRefresh: _loadAllReports,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Active Users',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${activity.length}',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'User Activity Details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...activity.map((user) {
            final lastActivity = user['last_activity'];
            final hasActivity = lastActivity != null;

            return Card(
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: hasActivity
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                  child: Text(
                    user['user_name'][0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(user['user_name']),
                subtitle: Text(user['user_email']),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${user['total_chats']} chats',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${user['total_tests']} tests',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatRow('Total Chats', '${user['total_chats']}'),
                        _buildStatRow('Total Tests', '${user['total_tests']}'),
                        const Divider(),
                        if (hasActivity) ...[
                          Text(
                            'Last Activity',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            DateFormat('MMM dd, yyyy - hh:mm a')
                                .format(DateTime.parse(lastActivity)),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ] else
                          const Text('No activity yet'),
                        const SizedBox(height: 8),
                        Text(
                          'Member Since',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          DateFormat('MMM dd, yyyy')
                              .format(DateTime.parse(user['created_at'])),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}