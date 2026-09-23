import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vision_companion/features/detector/cubit/detector_cubit.dart';
import 'package:vision_companion/features/detector/cubit/detector_state.dart';
import 'package:vision_companion/features/detector/models/detection.dart';
import 'package:vision_companion/features/detector/services/detector_service.dart';
import 'package:vision_companion/features/detector/services/tflite_detector_isolate.dart';
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

class FakeDetectorService implements DetectorService {
  bool initialized = false;
  bool shouldThrow = false;
  InferenceResult? nextResult;

  @override
  bool get isInitialized => initialized;

  @override
  Future<void> initialize({String modelPath = 'assets/models/2.tflite'}) async {
    if (shouldThrow) {
      throw Exception('Model file not found');
    }
    initialized = true;
  }

  @override
  Future<InferenceResult?> processCameraImage(
    CameraImage image, {
    int sensorOrientation = 90,
    double confidenceThreshold = 0.45,
  }) async {
    return nextResult;
  }

  @override
  void dispose() {
    initialized = false;
  }
}

void main() {
  group('DetectorCubit', () {
    late MockHistoryRepository mockHistoryRepo;
    late FakeDetectorService fakeDetectorService;
    late DetectorCubit cubit;

    setUp(() {
      mockHistoryRepo = MockHistoryRepository();
      fakeDetectorService = FakeDetectorService();
      cubit = DetectorCubit(
        detectorService: fakeDetectorService,
        historyRepository: mockHistoryRepo,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is DetectorInitial (Idle)', () {
      expect(cubit.state, equals(const DetectorInitial()));
      expect(cubit.state, isA<DetectorIdle>());
    });

    test('initialize loads detector service successfully', () async {
      await cubit.initialize();
      expect(fakeDetectorService.initialized, isTrue);
      expect(cubit.state, equals(const DetectorInitial()));
    });

    test('initialize emits DetectorError when model loading fails', () async {
      fakeDetectorService.shouldThrow = true;
      await cubit.initialize();
      expect(cubit.state, isA<DetectorError>());
      expect((cubit.state as DetectorError).message, contains('Failed to initialize TFLite model'));
    });

    test('startDetection emits DetectorRunning and coordinates with HistoryRepository', () async {
      await cubit.startDetection();
      expect(cubit.state, equals(const DetectorRunning(detectedObjects: [])));
      expect(mockHistoryRepo.loggedCalls.length, equals(1));
      expect(mockHistoryRepo.loggedCalls.first['type'], equals('detection'));
    });

    test('stopDetection emits DetectorStopped (Idle)', () async {
      await cubit.startDetection();
      cubit.stopDetection();
      expect(cubit.state, equals(const DetectorStopped()));
    });

    test('updateDetectedObjects updates detectedObjects and emits DetectorResults', () async {
      await cubit.startDetection();
      await cubit.updateDetectedObjects(['cup', 'bottle']);

      expect(cubit.state, isA<DetectorResults>());
      final resultsState = cubit.state as DetectorResults;
      expect(resultsState.detectedObjects, equals(['cup', 'bottle']));
      expect(resultsState.detections.length, equals(2));
      expect(resultsState.detections.first.label, equals('cup'));
      expect(resultsState.detections.last.label, equals('bottle'));
    });

    test('logDetectionResult delegates to HistoryRepository', () async {
      final docId = await cubit.logDetectionResult('Detected 2 items: cup, bottle');

      expect(docId, equals('detection_doc_1'));
      expect(mockHistoryRepo.loggedCalls.length, equals(1));
      expect(mockHistoryRepo.loggedCalls.first['type'], equals('detection'));
      expect(mockHistoryRepo.loggedCalls.first['summary'], equals('Detected 2 items: cup, bottle'));
    });

    test('DetectorResults holds detections and inferenceTimeMs', () {
      const detection = Detection(
        label: 'person',
        classId: 0,
        confidence: 0.95,
        boundingBox: Rect.fromLTWH(0.1, 0.1, 0.4, 0.6),
      );

      const state = DetectorResults(
        detections: [detection],
        inferenceTimeMs: 42,
      );

      expect(state.detections.length, equals(1));
      expect(state.inferenceTimeMs, equals(42));
      expect(state.detectedObjects, equals(['person']));
      expect(state.detections.first.confidencePercentage, equals(95));
    });
  });
}
