import 'package:flutter_test/flutter_test.dart';
import 'package:vision_companion/features/analyzer/cubit/analyzer_cubit.dart';
import 'package:vision_companion/features/analyzer/cubit/analyzer_state.dart';
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
  group('AnalyzerCubit', () {
    late MockHistoryRepository mockHistoryRepo;
    late AnalyzerCubit cubit;

    setUp(() {
      mockHistoryRepo = MockHistoryRepository();
      cubit = AnalyzerCubit(historyRepository: mockHistoryRepo);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is AnalyzerInitial', () {
      expect(cubit.state, equals(const AnalyzerInitial()));
    });

    test('analyzeImage emits Loading then Success and logs analysis to HistoryRepository', () async {
      final states = <AnalyzerState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.analyzeImage('/path/to/image.jpg');
      await pumpEventQueue();

      expect(states.length, equals(2));
      expect(states[0], isA<AnalyzerLoading>());
      expect(states[1], isA<AnalyzerSuccess>());

      final success = states[1] as AnalyzerSuccess;
      expect(success.imagePath, equals('/path/to/image.jpg'));
      expect(success.description, contains('AI Image Analysis'));

      // Verify that analysis was logged to HistoryRepository
      expect(mockHistoryRepo.loggedCalls.length, equals(1));
      expect(mockHistoryRepo.loggedCalls.first['type'], equals('analysis'));
      expect(mockHistoryRepo.loggedCalls.first['summary'], contains('AI Image Analysis'));
      expect(mockHistoryRepo.loggedCalls.first['metadata'], equals({'imagePath': '/path/to/image.jpg'}));

      await subscription.cancel();
    });

    test('logAnalysisResult directly logs to HistoryRepository', () async {
      final docId = await cubit.logAnalysisResult('Direct analysis summary');

      expect(docId, equals('analysis_doc_1'));
      expect(mockHistoryRepo.loggedCalls.length, equals(1));
      expect(mockHistoryRepo.loggedCalls.first['type'], equals('analysis'));
      expect(mockHistoryRepo.loggedCalls.first['summary'], equals('Direct analysis summary'));
    });

    test('reset emits AnalyzerInitial', () async {
      await cubit.analyzeImage('/path/to/image.jpg');
      cubit.reset();
      expect(cubit.state, equals(const AnalyzerInitial()));
    });
  });
}
