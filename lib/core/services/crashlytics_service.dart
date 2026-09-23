import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

abstract class CrashlyticsService {
  Future<void> initialize();
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool fatal = false,
  });
  Future<void> log(String message);
  Future<void> setUserId(String userId);
  Future<void> setCustomKey(String key, Object value);
}

class FirebaseCrashlyticsService implements CrashlyticsService {
  final FirebaseCrashlytics? crashlytics;

  const FirebaseCrashlyticsService({this.crashlytics});

  FirebaseCrashlytics? get _instance {
    if (crashlytics != null) return crashlytics;
    try {
      return FirebaseCrashlytics.instance;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> initialize() async {
    try {
      final instance = _instance;
      if (instance == null) return;

      // In debug mode, crash collection can be disabled or enabled for testing
      await instance.setCrashlyticsCollectionEnabled(!kDebugMode);

      // Automatically capture all errors that are thrown within the Flutter framework
      FlutterError.onError = (FlutterErrorDetails details) {
        if (kDebugMode) {
          FlutterError.presentError(details);
        }
        instance.recordFlutterFatalError(details);
      };

      // Automatically capture all asynchronous errors that aren't handled by the Flutter framework
      PlatformDispatcher.instance.onError = (error, stack) {
        instance.recordError(error, stack, fatal: true);
        return true;
      };
    } catch (e) {
      debugPrint('Crashlytics initialization notice: $e');
    }
  }

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool fatal = false,
  }) async {
    try {
      await _instance?.recordError(
        exception,
        stack,
        reason: reason,
        information: information,
        fatal: fatal,
      );
    } catch (e) {
      debugPrint('Crashlytics recordError notice: $e');
    }
  }

  @override
  Future<void> log(String message) async {
    try {
      await _instance?.log(message);
    } catch (e) {
      debugPrint('Crashlytics log notice: $e');
    }
  }

  @override
  Future<void> setUserId(String userId) async {
    try {
      await _instance?.setUserIdentifier(userId);
    } catch (e) {
      debugPrint('Crashlytics setUserId notice: $e');
    }
  }

  @override
  Future<void> setCustomKey(String key, Object value) async {
    try {
      await _instance?.setCustomKey(key, value);
    } catch (e) {
      debugPrint('Crashlytics setCustomKey notice: $e');
    }
  }
}
