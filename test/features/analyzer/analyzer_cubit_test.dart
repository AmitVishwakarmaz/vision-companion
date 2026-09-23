import 'package:flutter_test/flutter_test.dart';
import 'package:vision_companion/features/analyzer/cubit/analyzer_cubit.dart';
import 'package:vision_companion/features/analyzer/cubit/analyzer_state.dart';
import 'package:vision_companion/features/analyzer/models/analysis_data.dart';
import 'package:vision_companion/features/analyzer/services/gemini_vision_service.dart';
import 'package:vision_companion/features/analyzer/services/vision_service.dart';
import 'package:vision_companion/features/history/models/history_entry.dart';
import 'package:vision_companion/features/history/repositories/history_repository.dart';

class MockVisionService implements VisionService {
  String? mockResult;
  Exception? mockError;
  int callCount = 0;
  String? lastImagePath;
  String? lastApiKey;
  String? lastModel;

  @override
  Future<String> analyzeImage({
    required String imagePath,
    required String apiKey,
    String? prompt,
    String? model,
    String languageCode = 'en',
    Duration timeout = const Duration(seconds: 30),
  }) async {
    callCount++;
    lastImagePath = imagePath;
    lastApiKey = apiKey;
    lastModel = model;

    if (mockError != null) {
      throw mockError!;
    }
    return mockResult ?? 'A white coffee cup sitting on a polished wooden table next to a notebook.';
  }
}

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
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AnalyzerCubit with Vision Service Integration', () {
    late MockHistoryRepository mockHistoryRepo;
    late MockVisionService mockVisionService;
    late AnalyzerCubit cubit;

    setUp(() {
      mockHistoryRepo = MockHistoryRepository();
      mockVisionService = MockVisionService();
      cubit = AnalyzerCubit(
        visionService: mockVisionService,
        historyRepository: mockHistoryRepo,
        apiKeyProvider: () => 'test_mock_gemini_key_12345',
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is AnalyzerIdle', () {
      expect(cubit.state, equals(const AnalyzerIdle()));
    });

    test('analyzeImage emits Processing then Result(AnalysisData)', () async {
      mockVisionService.mockResult = 'A laptop open on a desk showing code editor.';

      final states = <AnalyzerState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.analyzeImage('/path/to/test_image.jpg');
      await pumpEventQueue();

      expect(states.length, equals(2));
      expect(states[0], isA<AnalyzerProcessing>());
      expect(states[1], isA<AnalyzerResult>());

      final result = states[1] as AnalyzerResult;
      expect(result.data, isA<AnalysisData>());
      expect(result.description, equals('A laptop open on a desk showing code editor.'));
      expect(result.imagePath, equals('/path/to/test_image.jpg'));
      expect(result.data.model, equals(GeminiVisionService.defaultModel));

      // Verify Vision service was called with sanitized API key
      expect(mockVisionService.callCount, equals(1));
      expect(mockVisionService.lastApiKey, equals('test_mock_gemini_key_12345'));

      // Verify Firestore history logged without Firebase Storage upload
      expect(mockHistoryRepo.loggedCalls.length, equals(1));
      expect(mockHistoryRepo.loggedCalls.first['type'], equals('analysis'));
      expect(mockHistoryRepo.loggedCalls.first['summary'], contains('A laptop open on a desk'));
      expect(mockHistoryRepo.loggedCalls.first['metadata']?['source'], equals('gemini_vision'));

      await subscription.cancel();
    });

    test('analyzeImage sanitizes surrounding quotes from API key', () async {
      final quotedCubit = AnalyzerCubit(
        visionService: mockVisionService,
        historyRepository: mockHistoryRepo,
        apiKeyProvider: () => '"AIzaSy_quoted_key_123"',
      );

      await quotedCubit.analyzeImage('/path/to/test.jpg');
      expect(mockVisionService.lastApiKey, equals('AIzaSy_quoted_key_123'));
      quotedCubit.close();
    });

    test('analyzeImage emits friendly AnalyzerError when API key is missing', () async {
      final emptyKeyCubit = AnalyzerCubit(
        visionService: mockVisionService,
        historyRepository: mockHistoryRepo,
        apiKeyProvider: () => '',
      );

      final states = <AnalyzerState>[];
      final subscription = emptyKeyCubit.stream.listen(states.add);

      await emptyKeyCubit.analyzeImage('/path/to/photo.jpg');
      await pumpEventQueue();

      expect(states.length, equals(2));
      expect(states[0], isA<AnalyzerProcessing>());
      expect(states[1], isA<AnalyzerError>());

      final errorState = states[1] as AnalyzerError;
      expect(errorState.message, contains('GEMINI_API_KEY'));
      expect(errorState.message, isNot(contains('#0'))); // No raw stack trace
      expect(errorState.failedImagePath, equals('/path/to/photo.jpg'));

      await subscription.cancel();
      emptyKeyCubit.close();
    });

    test('analyzeImage emits friendly error on GeminiAuthException', () async {
      mockVisionService.mockError = const GeminiAuthException(
        'Invalid Gemini API key. Please check your GEMINI_API_KEY in .env.',
      );

      final states = <AnalyzerState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.analyzeImage('/path/to/photo.jpg');
      await pumpEventQueue();

      expect(states.length, equals(2));
      expect(states[0], isA<AnalyzerProcessing>());
      expect(states[1], isA<AnalyzerError>());

      final errorState = states[1] as AnalyzerError;
      expect(errorState.message, contains('Invalid Gemini API key'));
      expect(errorState.message, isNot(contains('Exception:'))); // Clean friendly message
      expect(errorState.message, isNot(contains('dart:'))); // No stack traces

      await subscription.cancel();
    });

    test('analyzeImage emits friendly error on network failure without raw stack traces', () async {
      mockVisionService.mockError = const GeminiNetworkException(
        'Network error: Unable to reach Gemini AI. Please check your internet connection.',
      );

      final states = <AnalyzerState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.analyzeImage('/path/to/photo.jpg');
      await pumpEventQueue();

      expect(states.length, equals(2));
      expect(states[0], isA<AnalyzerProcessing>());
      expect(states[1], isA<AnalyzerError>());

      final errorState = states[1] as AnalyzerError;
      expect(errorState.message, contains('Network error'));
      expect(errorState.message, isNot(contains('Exception:'))); // Clean friendly message
      expect(errorState.message, isNot(contains('dart:'))); // No stack traces

      await subscription.cancel();
    });

    test('retry re-analyzes the failed image path', () async {
      mockVisionService.mockError = const GeminiNetworkException('Connection timeout');

      await cubit.analyzeImage('/path/to/failed.jpg');
      expect(cubit.state, isA<AnalyzerError>());

      // Fix error and retry
      mockVisionService.mockError = null;
      mockVisionService.mockResult = 'Successful retry description.';

      await cubit.retry();

      expect(cubit.state, isA<AnalyzerResult>());
      final result = cubit.state as AnalyzerResult;
      expect(result.description, equals('Successful retry description.'));
      expect(result.imagePath, equals('/path/to/failed.jpg'));
      expect(mockVisionService.callCount, equals(2));
    });

    test('reset restores state to AnalyzerIdle', () async {
      await cubit.analyzeImage('/path/to/photo.jpg');
      expect(cubit.state, isA<AnalyzerResult>());

      cubit.reset();
      expect(cubit.state, equals(const AnalyzerIdle()));
    });
  });
}
