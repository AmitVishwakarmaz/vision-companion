import 'package:equatable/equatable.dart';

/// Data model representing the result of an AI scene analysis from Groq Vision.
class AnalysisData extends Equatable {
  final String description;
  final String imagePath;
  final String model;
  final int latencyMs;
  final DateTime timestamp;

  const AnalysisData({
    required this.description,
    required this.imagePath,
    this.model = 'meta-llama/llama-4-scout-17b-16e-instruct',
    this.latencyMs = 0,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'imagePath': imagePath,
      'model': model,
      'latencyMs': latencyMs,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AnalysisData.fromMap(Map<String, dynamic> map) {
    return AnalysisData(
      description: map['description'] as String? ?? '',
      imagePath: map['imagePath'] as String? ?? '',
      model: map['model'] as String? ?? 'meta-llama/llama-4-scout-17b-16e-instruct',
      latencyMs: (map['latencyMs'] as num?)?.toInt() ?? 0,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [description, imagePath, model, latencyMs, timestamp];
}
