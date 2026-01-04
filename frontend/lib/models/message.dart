class Message {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final double? confidence;
  final double? responseTime;
  final List<String>? sources;
  final int? rating;
  final bool isError;


  Message({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.confidence,
    this.responseTime,
    this.sources,
    this.rating,
    this.isError = false,
  });

  Message copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    double? confidence,
    double? responseTime,
    List<String>? sources,
    int? rating,
    bool? isError,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      confidence: confidence ?? this.confidence,
      responseTime: responseTime ?? this.responseTime,
      sources: sources ?? this.sources,
      rating: rating ?? this.rating,
      isError: isError ?? this.isError,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'confidence': confidence,
      'responseTime': responseTime,
      'sources': sources,
      'rating': rating,
      'isError': isError,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    // Safe parsing for doubles
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    // Safe parsing for sources list
    List<String>? parseSources(dynamic value) {
      if (value == null) return null;
      if (value is List) return List<String>.from(value);
      if (value is String) return value.split(',').map((e) => e.trim()).toList();
      return null;
    }

    return Message(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
      confidence: parseDouble(json['confidence']),
      responseTime: parseDouble(json['responseTime']),
      sources: parseSources(json['sources']),
      rating: json['rating'] != null ? int.tryParse(json['rating'].toString()) : null,
      isError: json['isError'] ?? false,
    );
  }
}
