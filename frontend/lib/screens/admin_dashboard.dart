import 'package:flutter/material.dart';
import '../widgets/metric_card.dart';
import '../widgets/line_chart.dart';
import '../widgets/pie_chart.dart';
import 'admin_reports_screen.dart';
import 'login_screen.dart';


class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Hardcoded data as integers for PieChartWidget
    final intentDistribution = <String, int>{'Query': 50, 'Feedback': 30, 'Other': 20};
    final topicDistribution = <String, int>{'King': 40, 'Temple': 30, 'Festival': 30};

    // Line chart data
    final trainingMetrics = [
      {'step': 1, 'loss': 8}, // use int for simplicity
      {'step': 2, 'loss': 6},
      {'step': 3, 'loss': 4},
    ];

    final queryTimes = [
      {'query': 'Who was king?', 'time': 23}, // multiply by 10 to keep int
      {'query': 'Temple history', 'time': 17},
      {'query': 'Sri Lanka festivals', 'time': 20},
    ];

    final userFeedbacks = [
      {'userName': 'disara', 'query': 'Who was king?', 'rating': 5},
      {'userName': 'user2', 'query': 'Temple history', 'rating': 4},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF004C7A),
        actions: [
          IconButton(
  icon: const Icon(Icons.logout),
  tooltip: 'Logout',
  onPressed: () {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) =>  LoginScreen()),
      (route) => false, // removes all previous routes
    );
  },
),

          
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'View Reports',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminReportsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---------------- PIE CHARTS ----------------
            MetricCard(
              title: 'Intent Distribution',
              child: PieChartWidget(data: intentDistribution),
            ),
            const SizedBox(height: 16),
            MetricCard(
              title: 'Topic Distribution',
              child: PieChartWidget(data: topicDistribution),
            ),
            const SizedBox(height: 16),
            // ---------------- TRAINING LOSS ----------------
            MetricCard(
              title: 'Training Loss',
              child: LineChartWidget<Map<String, Object>>(
                points: trainingMetrics,
                xValue: (e) => (e['step'] as int).toDouble(),
                yValue: (e) => (e['loss'] as int).toDouble(),
              ),
            ),
            const SizedBox(height: 16),
            // ---------------- QUERY TIMES ----------------
            MetricCard(
              title: 'Query Times',
              child: LineChartWidget<Map<String, Object>>(
                points: queryTimes,
                xValue: (e) => queryTimes.indexOf(e).toDouble(),
                yValue: (e) => (e['time'] as int).toDouble(),
                xLabel: (e) => e['query'] as String,
              ),
            ),
            const SizedBox(height: 16),
            // ---------------- USER FEEDBACK ----------------
            MetricCard(
              title: 'User Feedback',
              child: Column(
                children: userFeedbacks.map((feedback) {
                  final userName = feedback['userName'] as String;
                  final query = feedback['query'] as String;
                  final rating = feedback['rating'] as int;

                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(userName[0].toUpperCase()),
                    ),
                    title: Text(query),
                    subtitle: Text('Rating: $rating ⭐'),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
