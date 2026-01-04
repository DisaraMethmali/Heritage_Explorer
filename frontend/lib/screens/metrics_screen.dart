class MetricsSummaryCard extends StatelessWidget {
  final Metrics metrics;
  

  const MetricsSummaryCard({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final avgRating = metrics.userRatings.isEmpty
        ? 0.0
        : metrics.userRatings.map((e) => e.rating).reduce((a, b) => a + b) /
            metrics.userRatings.length;

    final avgRetrievalTime = metrics.ragPerformance.isEmpty
        ? 0.0
        : metrics.ragPerformance
                .map((e) => e.retrievalTime)
                .reduce((a, b) => a + b) /
            metrics.ragPerformance.length;

    final latestLoss = metrics.trainingMetrics.isEmpty
        ? 0.0
        : metrics.trainingMetrics.last.loss;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Metrics Summary',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem(
                'Avg Rating',
                avgRating.toStringAsFixed(2),
                Icons.star,
                Colors.amber,
              ),
              _buildMetricItem(
                'Training Loss',
                latestLoss.toStringAsFixed(3),
                Icons.trending_down,
                Colors.red,
              ),
              _buildMetricItem(
                'Avg Retrieval',
                '${(avgRetrievalTime * 1000).toStringAsFixed(0)}ms',
                Icons.speed,
                Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem(
                'Total Queries',
                metrics.ragPerformance.length.toString(),
                Icons.question_answer,
                Colors.blue,
              ),
              _buildMetricItem(
                'Total Ratings',
                metrics.userRatings.length.toString(),
                Icons.rate_review,
                Colors.purple,
              ),
              _buildMetricItem(
                'RL Rewards',
                metrics.rlRewards.length.toString(),
                Icons.psychology,
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

// ============================================================================
// 5. MAIN METRICS SCREEN
// ============================================================================

class MetricsScreen extends StatefulWidget {
  const MetricsScreen({super.key});

  @override
  State<MetricsScreen> createState() => _MetricsScreenState();
}

class _MetricsScreenState extends State<MetricsScreen> {
  final MetricsService _service = MetricsService();
  Metrics? _metrics;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final metrics = await _service.fetchMetrics();
      setState(() {
        _metrics = metrics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metrics Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMetrics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      ElevatedButton(
                        onPressed: _loadMetrics,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _metrics == null
                  ? const Center(child: Text('No data available'))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        TrainingLossChart(data: _metrics!.trainingMetrics),
                        const SizedBox(height: 24),
                        RagPerformanceChart(data: _metrics!.ragPerformance),
                        const SizedBox(height: 24),
                        RlRewardsChart(data: _metrics!.rlRewards),
                        const SizedBox(height: 24),
                        UserRatingsChart(data: _metrics!.userRatings),
                        const SizedBox(height: 24),
                        RetrievalTimeChart(data: _metrics!.ragPerformance),
                      ],
                    ),
    );
  }
}