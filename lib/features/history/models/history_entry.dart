import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class HistoryEntry extends Equatable {
  final String id;
  final String featureType;
  final String resultSummary;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const HistoryEntry({
    required this.id,
    required this.featureType,
    required this.resultSummary,
    required this.timestamp,
    this.metadata,
  });

  factory HistoryEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return HistoryEntry.fromMap(data, id: doc.id);
  }

  factory HistoryEntry.fromMap(Map<String, dynamic> map, {String id = ''}) {
    DateTime parsedDate = DateTime.now();
    final rawTs = map['timestamp'];
    if (rawTs is Timestamp) {
      parsedDate = rawTs.toDate();
    } else if (rawTs is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(rawTs);
    } else if (rawTs is String) {
      parsedDate = DateTime.tryParse(rawTs) ?? DateTime.now();
    }

    return HistoryEntry(
      id: id,
      featureType: map['featureType'] as String? ?? '',
      resultSummary: map['resultSummary'] as String? ?? '',
      timestamp: parsedDate,
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toMap({bool useServerTimestamp = false}) {
    return {
      'timestamp': useServerTimestamp
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(timestamp),
      'featureType': featureType,
      'resultSummary': resultSummary,
      if (metadata != null) 'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [id, featureType, resultSummary, timestamp, metadata];
}
