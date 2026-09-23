import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vision_companion/core/constants/app_constants.dart';
import 'package:vision_companion/features/history/models/history_entry.dart';
import 'package:vision_companion/features/history/repositories/history_repository.dart';

class MockUser extends Fake implements User {
  @override
  final String uid;
  MockUser(this.uid);
}

class MockFirebaseAuth extends Fake implements FirebaseAuth {
  final User? _user;
  MockFirebaseAuth([this._user]);

  @override
  User? get currentUser => _user;
}

class FakeHistoryRepository implements HistoryRepository {
  final List<HistoryEntry> entries = [];
  bool shouldThrow = false;

  @override
  Future<String> logHistory({
    String? uid,
    required String featureType,
    required String resultSummary,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  }) async {
    if (shouldThrow) {
      throw const HistoryException('Database error');
    }
    final id = 'doc_${entries.length + 1}';
    final entry = HistoryEntry(
      id: id,
      featureType: featureType,
      resultSummary: resultSummary,
      timestamp: timestamp ?? DateTime.now(),
      metadata: metadata,
    );
    entries.add(entry);
    if (entries.length > AppConstants.maxHistoryEntries) {
      entries.removeRange(0, entries.length - AppConstants.maxHistoryEntries);
    }
    return id;
  }

  @override
  Future<String> logDetection({
    String? uid,
    required String resultSummary,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  }) {
    return logHistory(
      uid: uid,
      featureType: AppConstants.featureTypeDetector,
      resultSummary: resultSummary,
      metadata: metadata,
      timestamp: timestamp,
    );
  }

  @override
  Future<String> logAnalysis({
    String? uid,
    required String resultSummary,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  }) {
    return logHistory(
      uid: uid,
      featureType: AppConstants.featureTypeAnalyzer,
      resultSummary: resultSummary,
      metadata: metadata,
      timestamp: timestamp,
    );
  }

  @override
  Future<List<HistoryEntry>> getHistory({
    String? uid,
    int limit = 50,
    String? featureType,
  }) async {
    if (shouldThrow) throw const HistoryException('Database error');
    var result = List<HistoryEntry>.from(entries);
    if (featureType != null) {
      result = result.where((e) => e.featureType == featureType).toList();
    }
    return result.reversed.take(limit).toList();
  }

  @override
  Stream<List<HistoryEntry>> streamHistory({
    String? uid,
    int limit = 50,
    String? featureType,
  }) {
    return Stream.value(entries);
  }

  @override
  Future<void> deleteHistoryEntry({
    String? uid,
    required String docId,
  }) async {
    entries.removeWhere((e) => e.id == docId);
  }
}

void main() {
  group('HistoryEntry Model', () {
    test('serializes to map with required fields (timestamp, featureType, resultSummary)', () {
      final now = DateTime(2026, 9, 23, 12, 0, 0);
      final entry = HistoryEntry(
        id: 'doc_123',
        featureType: AppConstants.featureTypeDetector,
        resultSummary: 'Detected person, cup',
        timestamp: now,
        metadata: {'confidence': 0.95},
      );

      final map = entry.toMap();

      expect(map['featureType'], equals(AppConstants.featureTypeDetector));
      expect(map['resultSummary'], equals('Detected person, cup'));
      expect(map['timestamp'], isA<Timestamp>());
      expect((map['timestamp'] as Timestamp).toDate(), equals(now));
      expect(map['metadata'], equals({'confidence': 0.95}));
    });

    test('supports server timestamp in toMap', () {
      final entry = HistoryEntry(
        id: 'doc_456',
        featureType: AppConstants.featureTypeAnalyzer,
        resultSummary: 'A kitchen with a kettle on the stove',
        timestamp: DateTime.now(),
      );

      final map = entry.toMap(useServerTimestamp: true);

      expect(map['timestamp'], isA<FieldValue>());
      expect(map['featureType'], equals(AppConstants.featureTypeAnalyzer));
      expect(map['resultSummary'], equals('A kitchen with a kettle on the stove'));
    });

    test('deserializes from map with Timestamp and Map metadata', () {
      final now = DateTime(2026, 9, 23, 12, 0, 0);
      final map = {
        'timestamp': Timestamp.fromDate(now),
        'featureType': AppConstants.featureTypeDetector,
        'resultSummary': 'Detected chair, table',
        'metadata': {'count': 2},
      };

      final entry = HistoryEntry.fromMap(map, id: 'doc_789');

      expect(entry.id, equals('doc_789'));
      expect(entry.featureType, equals(AppConstants.featureTypeDetector));
      expect(entry.resultSummary, equals('Detected chair, table'));
      expect(entry.timestamp, equals(now));
      expect(entry.metadata, equals({'count': 2}));
    });

    test('deserializes from map with integer millisecond timestamp', () {
      final nowMillis = 1790164800000;
      final map = {
        'timestamp': nowMillis,
        'featureType': AppConstants.featureTypeAnalyzer,
        'resultSummary': 'Document analysis result',
      };

      final entry = HistoryEntry.fromMap(map, id: 'doc_int');
      expect(entry.timestamp, equals(DateTime.fromMillisecondsSinceEpoch(nowMillis)));
    });

    test('equality and props support', () {
      final now = DateTime(2026, 9, 23);
      final e1 = HistoryEntry(
        id: '1',
        featureType: 'detector',
        resultSummary: 'dog',
        timestamp: now,
      );
      final e2 = HistoryEntry(
        id: '1',
        featureType: 'detector',
        resultSummary: 'dog',
        timestamp: now,
      );

      expect(e1, equals(e2));
    });
  });

  group('FirestoreHistoryRepository Auth Validation', () {
    test('throws HistoryException when no UID provided and FirebaseAuth has no user', () async {
      final emptyAuth = MockFirebaseAuth(null);
      final repo = FirestoreHistoryRepository(firebaseAuth: emptyAuth);

      expect(
        () => repo.logHistory(
          featureType: AppConstants.featureTypeDetector,
          resultSummary: 'test',
        ),
        throwsA(isA<HistoryException>()),
      );

      expect(
        () => repo.getHistory(),
        throwsA(isA<HistoryException>()),
      );
    });

    test('FakeHistoryRepository logs detection and analysis with correct featureType', () async {
      final fakeRepo = FakeHistoryRepository();

      final detId = await fakeRepo.logDetection(
        uid: 'user_1',
        resultSummary: 'Detected phone, laptop',
      );
      expect(detId, equals('doc_1'));
      expect(fakeRepo.entries.first.featureType, equals(AppConstants.featureTypeDetector));
      expect(fakeRepo.entries.first.resultSummary, equals('Detected phone, laptop'));

      final anId = await fakeRepo.logAnalysis(
        uid: 'user_1',
        resultSummary: 'A person holding a book in the library',
      );
      expect(anId, equals('doc_2'));
      expect(fakeRepo.entries.last.featureType, equals(AppConstants.featureTypeAnalyzer));
      expect(fakeRepo.entries.last.resultSummary, equals('A person holding a book in the library'));

      final history = await fakeRepo.getHistory(uid: 'user_1');
      expect(history.length, equals(2));

      final detectorOnly = await fakeRepo.getHistory(
        uid: 'user_1',
        featureType: AppConstants.featureTypeDetector,
      );
      expect(detectorOnly.length, equals(1));
      expect(detectorOnly.first.resultSummary, equals('Detected phone, laptop'));
    });

    test('retains previous entries and enforces sliding limit of last 20 entries', () async {
      final fakeRepo = FakeHistoryRepository();

      for (int i = 1; i <= 25; i++) {
        await fakeRepo.logHistory(
          featureType: i.isEven ? AppConstants.featureTypeDetector : AppConstants.featureTypeAnalyzer,
          resultSummary: 'Log entry #$i',
        );
      }

      final allLogs = await fakeRepo.getHistory();
      expect(allLogs.length, equals(AppConstants.maxHistoryEntries)); // exactly 20
      // Latest entry #25 is preserved at index 0
      expect(allLogs.first.resultSummary, equals('Log entry #25'));
      // Oldest retained entry is #6 (entries 1-5 were pruned)
      expect(allLogs.last.resultSummary, equals('Log entry #6'));
    });
  });
}
