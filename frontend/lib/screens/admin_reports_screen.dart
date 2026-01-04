import 'package:flutter/material.dart';
import '../widgets/metric_card.dart';
import '../widgets/line_chart.dart';
import '../widgets/pie_chart.dart';
import '../models/metrics.dart'; // Use models from here

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ---------------- HARD-CODED DATA ----------------
    final metrics = Metrics(
      intentDistribution: {
        "description": 1,
        "greeting": 1,
        "person": 1,
      },
      topicDistribution: {
        "festival": 1,
        "general": 1,
        "temple": 1,
      },
      trainingMetrics: [
        TrainingMetric(step: 10, loss: 2.7129),
        TrainingMetric(step: 20, loss: 2.3853),
        TrainingMetric(step: 30, loss: 2.1121),
        TrainingMetric(step: 40, loss: 1.781),
        TrainingMetric(step: 50, loss: 1.5927),
        TrainingMetric(step: 60, loss: 1.5843),
        TrainingMetric(step: 70, loss: 1.5027),
        TrainingMetric(step: 80, loss: 1.5344),
        TrainingMetric(step: 90, loss: 1.5156),
        TrainingMetric(step: 100, loss: 1.4673),
      ],
      queryTimes: [
        QueryTime(query: "What is Sri Dalada Maligawa?", time: 2.446),
        QueryTime(query: "Tell me about the Esala Perahera", time: 2.616),
      ],
    );

    // ---------------- UI ----------------
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Reports'),
        backgroundColor: const Color(0xFF004C7A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MetricCard(
              title: 'Intent Distribution',
              child: PieChartWidget(data: metrics.intentDistribution),
            ),
            const SizedBox(height: 16),
            MetricCard(
              title: 'Topic Distribution',
              child: PieChartWidget(data: metrics.topicDistribution),
            ),
            const SizedBox(height: 16),
            MetricCard(
              title: 'Training Loss',
              child: LineChartWidget<TrainingMetric>(
                points: metrics.trainingMetrics,
                xValue: (e) => e.step.toDouble(),
                yValue: (e) => e.loss,
              ),
            ),
            const SizedBox(height: 16),
            MetricCard(
              title: 'Query Times',
              child: LineChartWidget<QueryTime>(
                points: metrics.queryTimes,
                xValue: (e) => metrics.queryTimes.indexOf(e).toDouble(),
                yValue: (e) => e.time,
                xLabel: (e) => e.query,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
