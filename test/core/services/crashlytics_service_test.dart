import 'package:flutter_test/flutter_test.dart';
import 'package:vision_companion/core/services/crashlytics_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FirebaseCrashlyticsService Tests', () {
    test('Can be instantiated without throwing', () {
      const service = FirebaseCrashlyticsService();
      expect(service, isNotNull);
    });

    test('Methods handle null or uninitialized instance gracefully without throwing', () async {
      const service = FirebaseCrashlyticsService();

      // Initialize
      await expectLater(service.initialize(), completes);

      // Record error
      await expectLater(
        service.recordError(
          Exception('Test non-fatal exception'),
          StackTrace.current,
          reason: 'Testing crashlytics service fallback',
          fatal: false,
        ),
        completes,
      );

      // Log message
      await expectLater(service.log('Test crashlytics log message'), completes);

      // Set user id
      await expectLater(service.setUserId('user_12345'), completes);

      // Set custom key
      await expectLater(service.setCustomKey('test_key', 'test_value'), completes);
    });
  });
}
