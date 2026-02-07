// lib/models/metrics.dart

/// -------------------- DATA MODELS --------------------

/// Represents the execution time of a single query
class QueryTime {
  final String query;
  final double time;

  QueryTime({
    required this.query,
    required this.time,
  });

  /// Factory constructor for JSON deserialization
  factory QueryTime.fromJson(Map<String, dynamic> json) {
    return QueryTime(
      query: json['query'] as String,
      time: (json['time'] as num).toDouble(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'time': time,
    };
  }
}

/// Represents a training metric (step and loss)
class TrainingMetric {
  final int step;
  final double loss;

  TrainingMetric({
    required this.step,
    required this.loss,
  });

  /// Factory constructor for JSON deserialization
  factory TrainingMetric.fromJson(Map<String, dynamic> json) {
    return TrainingMetric(
      step: json['step'] as int,
      loss: (json['loss'] as num).toDouble(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'step': step,
      'loss': loss,
    };
  }
}

/// Represents all metrics for analytics
class Metrics {
  final Map<String, int> intentDistribution;
  final Map<String, int> topicDistribution;
  final List<TrainingMetric> trainingMetrics;
  final List<QueryTime> queryTimes;

  Metrics({
    required this.intentDistribution,
    required this.topicDistribution,
    required this.trainingMetrics,
    required this.queryTimes,
  });

  /// Factory constructor to create Metrics from JSON
  factory Metrics.fromJson(Map<String, dynamic> json) {
    return Metrics(
      intentDistribution: Map<String, int>.from(json['intent_distribution']),
      topicDistribution: Map<String, int>.from(json['topic_distribution']),
      trainingMetrics: (json['training_metrics'] as List)
          .map((e) => TrainingMetric.fromJson(e as Map<String, dynamic>))
          .toList(),
      queryTimes: (json['query_times'] as List)
          .map((e) => QueryTime.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convert Metrics object to JSON
  Map<String, dynamic> toJson() {
    return {
      'intent_distribution': intentDistribution,
      'topic_distribution': topicDistribution,
      'training_metrics':
          trainingMetrics.map((e) => e.toJson()).toList(),
      'query_times': queryTimes.map((e) => e.toJson()).toList(),
    };
  }
}
