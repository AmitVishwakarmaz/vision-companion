import 'package:equatable/equatable.dart';

/// Tag with confidence score extracted from or associated with scene analysis.
class AnalysisTag extends Equatable {
  final String label;
  final double confidence; // e.g. 0.94 for 94%

  const AnalysisTag({required this.label, required this.confidence});

  String get formattedConfidence => '${(confidence * 100).round()}%';
  String get semanticLabel => 'Tag: $label, $formattedConfidence confidence';

  Map<String, dynamic> toMap() => {
        'label': label,
        'confidence': confidence,
      };

  factory AnalysisTag.fromMap(Map<String, dynamic> map) => AnalysisTag(
        label: map['label'] as String? ?? '',
        confidence: (map['confidence'] as num?)?.toDouble() ?? 0.94,
      );

  @override
  List<Object?> get props => [label, confidence];
}

/// Data model representing the result of an AI scene analysis.
class AnalysisData extends Equatable {
  final String description;
  final String imagePath;
  final String model;
  final int latencyMs;
  final DateTime timestamp;
  final List<AnalysisTag> tags;

  const AnalysisData({
    required this.description,
    required this.imagePath,
    this.model = 'gemini-1.5-flash',
    this.latencyMs = 0,
    required this.timestamp,
    this.tags = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'imagePath': imagePath,
      'model': model,
      'latencyMs': latencyMs,
      'timestamp': timestamp.toIso8601String(),
      'tags': tags.map((t) => t.toMap()).toList(),
    };
  }

  factory AnalysisData.fromMap(Map<String, dynamic> map) {
    final rawTags = map['tags'] as List<dynamic>?;
    final List<AnalysisTag> parsedTags = rawTags != null
        ? rawTags
            .whereType<Map<String, dynamic>>()
            .map(AnalysisTag.fromMap)
            .toList()
        : const [];

    return AnalysisData(
      description: map['description'] as String? ?? '',
      imagePath: map['imagePath'] as String? ?? '',
      model: map['model'] as String? ?? 'gemini-1.5-flash',
      latencyMs: (map['latencyMs'] as num?)?.toInt() ?? 0,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      tags: parsedTags,
    );
  }

  /// Extracts tags from a raw response text, or infers primary subject tags.
  static ({String cleanDescription, List<AnalysisTag> tags}) parseWithTags(String rawText) {
    var text = rawText.trim();
    final List<AnalysisTag> tags = [];

    // Check for explicit "Tags:" or "Tag:" line in English or Hindi, including markdown formatting
    final tagsRegex = RegExp(
      r'(?:(?:\*\*|\*|\[)?(?:Tags?|Labels?|टैग|लेबल)(?:\*\*|\*|\])?:\s*)(.+)$',
      multiLine: true,
      caseSensitive: false,
    );
    final match = tagsRegex.firstMatch(text);

    if (match != null) {
      final tagsLine = match.group(1) ?? '';
      // Remove tags line from description so only natural sentence description remains
      text = text.replaceAll(match.group(0)!, '').trim();

      // Parse individual tags e.g. "air cooler (95%), appliance (90%)" or "cat: 94%"
      final parts = tagsLine.split(RegExp(r'[,;•]'));
      for (final part in parts) {
        // Matches Unicode letters, numbers, spaces, and hyphens before confidence
        final pMatch = RegExp(r'^\s*([^:\(\),;%]+?)(?:\s*[:\(]\s*(\d+)%?\)?|\s*$)').firstMatch(part);
        if (pMatch != null) {
          final label = pMatch.group(1)?.trim();
          final confStr = pMatch.group(2);
          if (label != null && label.isNotEmpty && label.toLowerCase() != 'none') {
            final conf = confStr != null ? (double.tryParse(confStr) ?? 94.0) / 100.0 : 0.94;
            tags.add(AnalysisTag(label: label, confidence: conf.clamp(0.5, 0.99)));
          }
        }
      }
    }

    // Fallback: If no explicit tags line found, intelligently extract top subject keywords
    if (tags.isEmpty) {
      final lower = text.toLowerCase();

      // 1. Currency identification
      if (lower.contains('banknote') || lower.contains('rupee') || text.contains('रुपये') || text.contains('नोट')) {
        tags.add(const AnalysisTag(label: 'banknote', confidence: 0.96));
        if (lower.contains('500') || text.contains('500')) {
          tags.add(const AnalysisTag(label: '500 rupees', confidence: 0.98));
        } else if (lower.contains('100') || text.contains('100')) {
          tags.add(const AnalysisTag(label: '100 rupees', confidence: 0.98));
        } else if (lower.contains('200') || text.contains('200')) {
          tags.add(const AnalysisTag(label: '200 rupees', confidence: 0.98));
        }
      }

      // 2. Dynamic subject extraction from introductory clause
      if (tags.isEmpty) {
        final subjectMatch = RegExp(
          r'(?:in front of you is (?:a|an)\s+|this is (?:a|an)\s+|there is (?:a|an)\s+|shows (?:a|an)\s+)([a-zA-Z0-9\s\-]+?)(?:\s+(?:standing|sitting|placed|located|with|on|in|,|\.))',
          caseSensitive: false,
        ).firstMatch(text);

        if (subjectMatch != null) {
          final rawSubject = subjectMatch.group(1)?.trim();
          if (rawSubject != null && rawSubject.isNotEmpty && rawSubject.length <= 30) {
            tags.add(AnalysisTag(label: rawSubject, confidence: 0.94));
          }
        }
      }

      // 3. Whole-word keyword matching (strictly using word boundaries \b to avoid substring false positives)
      if (tags.isEmpty) {
        if (RegExp(r'\b(?:cooler|air cooler|fan|ac)\b', caseSensitive: false).hasMatch(text)) {
          tags.add(const AnalysisTag(label: 'air cooler', confidence: 0.94));
        } else if (RegExp(r'\b(?:cat|kitten|feline)\b', caseSensitive: false).hasMatch(text)) {
          tags.add(const AnalysisTag(label: 'cat', confidence: 0.94));
        } else if (RegExp(r'\b(?:dog|puppy|canine)\b', caseSensitive: false).hasMatch(text)) {
          tags.add(const AnalysisTag(label: 'dog', confidence: 0.95));
        } else if (RegExp(r'\b(?:laptop|computer|macbook|pc)\b', caseSensitive: false).hasMatch(text)) {
          tags.add(const AnalysisTag(label: 'laptop', confidence: 0.95));
        } else if (RegExp(r'\b(?:person|man|woman|child|human)\b', caseSensitive: false).hasMatch(text)) {
          tags.add(const AnalysisTag(label: 'person', confidence: 0.92));
        } else if (RegExp(r'\b(?:chair|couch|sofa|table|desk|bed)\b', caseSensitive: false).hasMatch(text)) {
          tags.add(const AnalysisTag(label: 'furniture', confidence: 0.90));
        } else if (RegExp(r'\b(?:phone|cellphone|smartphone)\b', caseSensitive: false).hasMatch(text)) {
          tags.add(const AnalysisTag(label: 'cell phone', confidence: 0.95));
        } else if (RegExp(r'\b(?:bottle|cup|mug|glass)\b', caseSensitive: false).hasMatch(text)) {
          tags.add(const AnalysisTag(label: 'bottle', confidence: 0.93));
        }
      }
    }

    return (cleanDescription: text, tags: tags);
  }

  @override
  List<Object?> get props => [description, imagePath, model, latencyMs, timestamp, tags];
}
