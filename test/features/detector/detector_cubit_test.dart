import 'package:flutter_test/flutter_test.dart';
import 'package:vision_companion/features/detector/cubit/detector_cubit.dart';
import 'package:vision_companion/features/detector/cubit/detector_state.dart';
import 'package:vision_companion/features/history/models/history_entry.dart';
import 'package:vision_companion/features/history/repositories/history_repository.dart';

class MockHistoryRepository implements HistoryRepository {
  final List<Map<String, dynamic>> loggedCalls = [];

  @override
  Future<String> logDetection({
    String? uid,
    required String resultSummary,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  }) async {
    loggedCalls.add({
      'type': 'detection',
      'uid': uid,
      'summary': resultSummary,
      'metadata': metadata,
    });
    return 'detection_doc_1';
  }

  @override
  Future<String> logAnalysis({
    String? uid,
    required String resultSummary,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  }) async {
    loggedCalls.add({
      'type': 'analysis',
      'uid': uid,
      'summary': resultSummary,
      'metadata': metadata,
    });
    return 'analysis_doc_1';
  }

  @override
  Future<String> logHistory({
    String? uid,
    required String featureType,
    required String resultSummary,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  }) async => 'doc_1';

  @override
  Future<List<HistoryEntry>> getHistory({String? uid, int limit = 50, String? featureType}) async => [];

  @override
  Stream<List<HistoryEntry>> streamHistory({String? uid, int limit = 50, String? featureType}) =>
      const Stream.empty();

  @override
  Future<void> deleteHistoryEntry({String? uid, required String docId}) async {}
}

void main() {
  group('DetectorCubit', () {
    late MockHistoryRepository mockHistoryRepo;
    late DetectorCubit cubit;

    setUp(() {
      mockHistoryRepo = MockHistoryRepository();
      cubit = DetectorCubit(historyRepository: mockHistoryRepo);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is DetectorInitial', () {
      expect(cubit.state, equals(const DetectorInitial()));
    });

    test('startDetection emits DetectorRunning with empty list', () {
      cubit.startDetection();
      expect(cubit.state, equals(const DetectorRunning(detectedObjects: [])));
    });

    test('updateDetectedObjects updates detectedObjects when running', () {
      cubit.startDetection();
      cubit.updateDetectedObjects(['cup', 'bottle']);
      expect(cubit.state, equals(const DetectorRunning(detectedObjects: ['cup', 'bottle'])));
    });

    test('stopDetection emits DetectorStopped', () {
      cubit.startDetection();
      cubit.stopDetection();
      expect(cubit.state, equals(const DetectorStopped()));
    });

    test('logDetectionResult delegates to HistoryRepository', () async {
      final docId = await cubit.logDetectionResult('Detected 2 items: cup, bottle');

      expect(docId, equals('detection_doc_1'));
      expect(mockHistoryRepo.loggedCalls.length, equals(1));
      expect(mockHistoryRepo.loggedCalls.first['type'], equals('detection'));
      expect(mockHistoryRepo.loggedCalls.first['summary'], equals('Detected 2 items: cup, bottle'));
    });
  });
}
