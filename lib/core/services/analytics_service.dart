import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

abstract class AnalyticsService {
  Future<void> logFeatureOpened(String featureName);
  Future<void> logDetectionCompleted({
    required int count,
    required List<String> categories,
    int? latencyMs,
  });
  Future<void> logCustomEvent(String name, {Map<String, Object>? parameters});
}

class FirebaseAnalyticsService implements AnalyticsService {
  final FirebaseAnalytics? analytics;

  const FirebaseAnalyticsService({this.analytics});

  FirebaseAnalytics? get _instance {
    if (analytics != null) return analytics;
    try {
      return FirebaseAnalytics.instance;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logFeatureOpened(String featureName) async {
    try {
      await _instance?.logEvent(
        name: 'feature_opened',
        parameters: {'feature_name': featureName},
      );
    } catch (e) {
      debugPrint('Analytics notice (feature_opened): $e');
    }
  }

  @override
  Future<void> logDetectionCompleted({
    required int count,
    required List<String> categories,
    int? latencyMs,
  }) async {
    try {
      await _instance?.logEvent(
        name: 'detection_completed',
        parameters: {
          'count': count,
          'categories': categories.take(10).join(','),
          'latency_ms': ?latencyMs,
        },
      );
    } catch (e) {
      debugPrint('Analytics notice (detection_completed): $e');
    }
  }

  @override
  Future<void> logCustomEvent(String name, {Map<String, Object>? parameters}) async {
    try {
      await _instance?.logEvent(name: name, parameters: parameters);
    } catch (e) {
      debugPrint('Analytics notice ($name): $e');
    }
  }
}
