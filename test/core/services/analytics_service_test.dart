import 'package:flutter_test/flutter_test.dart';
import 'package:vision_companion/core/services/analytics_service.dart';

class MockAnalyticsService implements AnalyticsService {
  final List<String> openedFeatures = [];
  final List<Map<String, dynamic>> detectionCompletedEvents = [];
  final List<Map<String, dynamic>> imageAnalyzedEvents = [];
  final List<String?> userIds = [];
  final List<Map<String, dynamic>> customEvents = [];

  @override
  Future<void> logFeatureOpened(String featureName) async {
    openedFeatures.add(featureName);
  }

  @override
  Future<void> logDetectionCompleted({
    required int count,
    required List<String> categories,
    int? latencyMs,
  }) async {
    detectionCompletedEvents.add({
      'count': count,
      'categories': categories,
      'latencyMs': latencyMs,
    });
  }

  @override
  Future<void> logImageAnalyzed({
    String? model,
    int? latencyMs,
    int? tagsCount,
  }) async {
    imageAnalyzedEvents.add({
      'model': model,
      'latencyMs': latencyMs,
      'tagsCount': tagsCount,
    });
  }

  @override
  Future<void> setUserId(String? userId) async {
    userIds.add(userId);
  }

  @override
  Future<void> logCustomEvent(String name, {Map<String, Object>? parameters}) async {
    customEvents.add({'name': name, 'parameters': parameters});
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FirebaseAnalyticsService Fallback Tests', () {
    test('Can be instantiated without throwing', () {
      const service = FirebaseAnalyticsService();
      expect(service, isNotNull);
    });

    test('All analytics events execute gracefully without throwing when uninitialized', () async {
      const service = FirebaseAnalyticsService();

      await expectLater(service.logFeatureOpened('live_object_detector'), completes);
      await expectLater(
        service.logDetectionCompleted(
          count: 3,
          categories: ['chair', 'table', 'laptop'],
          latencyMs: 85,
        ),
        completes,
      );
      await expectLater(
        service.logImageAnalyzed(
          model: 'gemini-1.5-flash',
          latencyMs: 420,
          tagsCount: 5,
        ),
        completes,
      );
      await expectLater(service.setUserId('user_test_99'), completes);
      await expectLater(
        service.logCustomEvent('test_event', parameters: {'status': 'ok'}),
        completes,
      );
    });
  });

  group('MockAnalyticsService Event Verification', () {
    test('Logs feature_opened, detection_completed, and image_analyzed events accurately', () async {
      final mock = MockAnalyticsService();

      // feature_opened
      await mock.logFeatureOpened('live_object_detector');
      await mock.logFeatureOpened('image_analyzer');
      await mock.logFeatureOpened('settings');
      expect(mock.openedFeatures, equals(['live_object_detector', 'image_analyzer', 'settings']));

      // detection_completed
      await mock.logDetectionCompleted(
        count: 2,
        categories: ['person', 'dog'],
        latencyMs: 110,
      );
      expect(mock.detectionCompletedEvents.length, equals(1));
      expect(mock.detectionCompletedEvents.first['count'], equals(2));
      expect(mock.detectionCompletedEvents.first['categories'], equals(['person', 'dog']));
      expect(mock.detectionCompletedEvents.first['latencyMs'], equals(110));

      // image_analyzed
      await mock.logImageAnalyzed(
        model: 'gemini-1.5-flash',
        latencyMs: 750,
        tagsCount: 4,
      );
      expect(mock.imageAnalyzedEvents.length, equals(1));
      expect(mock.imageAnalyzedEvents.first['model'], equals('gemini-1.5-flash'));
      expect(mock.imageAnalyzedEvents.first['latencyMs'], equals(750));
      expect(mock.imageAnalyzedEvents.first['tagsCount'], equals(4));

      // setUserId
      await mock.setUserId('auth_user_777');
      expect(mock.userIds, equals(['auth_user_777']));
    });
  });
}
