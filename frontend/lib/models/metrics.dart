// lib/models/metrics.dart

class RlReward {
  final String name;
  final double value;

  RlReward({required this.name, required this.value});

  factory RlReward.fromJson(Map<String, dynamic> json) {
    return RlReward(
      name: json['name'] ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'value': value,
      };
}

class TrainingMetric {
  final int step;
  final double loss;

  TrainingMetric({required this.step, required this.loss});

  factory TrainingMetric.fromJson(Map<String, dynamic> json) {
    return TrainingMetric(
      step: json['step'] ?? 0,
      loss: (json['loss'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'step': step,
        'loss': loss,
      };
}

class QueryTime {
  final String query;
  final double time;

  QueryTime({required this.query, required this.time});

  factory QueryTime.fromJson(Map<String, dynamic> json) {
    return QueryTime(
      query: json['query'] ?? '',
      time: (json['time'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'query': query,
        'time': time,
      };
}

class Metrics {
  final List<TrainingMetric> trainingMetrics;
  final List<QueryTime> queryTimes;
  final Map<String, int> intentDistribution;
  final Map<String, int> topicDistribution;
  final List<RlReward> rlRewards; // ✅ now works

  Metrics({
    required this.trainingMetrics,
    required this.queryTimes,
    required this.intentDistribution,
    required this.topicDistribution,
    required this.rlRewards, // ✅ required
  });

  factory Metrics.fromJson(Map<String, dynamic> json) {
    return Metrics(
      trainingMetrics: (json['trainingMetrics'] as List<dynamic>?)
              ?.map((e) => TrainingMetric.fromJson(e))
              .toList() ??
          [],
      queryTimes: (json['queryTimes'] as List<dynamic>?)
              ?.map((e) => QueryTime.fromJson(e))
              .toList() ??
          [],
      intentDistribution:
          Map<String, int>.from(json['intentDistribution'] ?? {}),
      topicDistribution: Map<String, int>.from(json['topicDistribution'] ?? {}),
      rlRewards: (json['rlRewards'] as List<dynamic>?)
              ?.map((e) => RlReward.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'trainingMetrics': trainingMetrics.map((e) => e.toJson()).toList(),
        'queryTimes': queryTimes.map((e) => e.toJson()).toList(),
        'intentDistribution': intentDistribution,
        'topicDistribution': topicDistribution,
        'rlRewards': rlRewards.map((e) => e.toJson()).toList(),
      };
}
