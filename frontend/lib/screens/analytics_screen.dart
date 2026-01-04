import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/metrics_provider.dart';
import '../widgets/metric_card.dart';
import '../widgets/line_chart.dart';
import '../widgets/pie_chart.dart';
import '../services/metrics_export_service.dart';
import '../services/metrics_pdf_service.dart';
import 'package:open_file/open_file.dart';
import '../models/metrics.dart'; // important!

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MetricsProvider>().loadMetrics();
  }

  Future<void> _exportPdf() async {
    final provider = context.read<MetricsProvider>();
    if (provider.metrics == null) return;

    final file = await MetricsPdfService.generatePdf(provider.metrics!);
    if (file != null) {
      await OpenFile.open(file.path);
    }
  }

  Future<void> _exportCsv() async {
    final provider = context.read<MetricsProvider>();
    if (provider.metrics == null) return;

    final file = await MetricsExportService.generateCsv(provider.metrics!);
    if (file != null) {
      await OpenFile.open(file.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MetricsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Metrics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export PDF',
            onPressed: _exportPdf,
          ),
          IconButton(
            icon: const Icon(Icons.grid_on),
            tooltip: 'Export CSV',
            onPressed: _exportCsv,
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.metrics == null
              ? Center(child: Text(provider.error ?? 'No data'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Intent Distribution Pie Chart
                      MetricCard(
                        title: 'Intent Distribution',
                        child: PieChartWidget(
                          data: provider.metrics!.intentDistribution,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Topic Distribution Pie Chart
                      MetricCard(
                        title: 'Topic Distribution',
                        child: PieChartWidget(
                          data: provider.metrics!.topicDistribution,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Training Loss Line Chart (numeric X-axis)
                      MetricCard(
                        title: 'Training Loss',
                        child: LineChartWidget<TrainingMetric>(
                          points: provider.metrics!.trainingMetrics,
                          xValue: (e) => e.step.toDouble(),
                          yValue: (e) => e.loss,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Query Times Line Chart (string X-axis)
                      MetricCard(
                        title: 'Query Times',
                        child: LineChartWidget<QueryTime>(
                          points: provider.metrics!.queryTimes,
                          xValue: (e) => provider.metrics!.queryTimes.indexOf(e).toDouble(), // numeric X-axis
                          yValue: (e) => e.time,
                          xLabel: (e) => e.query, // string labels
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
