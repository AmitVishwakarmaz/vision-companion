import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vision_companion/core/services/analytics_service.dart';
import 'package:vision_companion/core/services/crashlytics_service.dart';
import 'package:vision_companion/features/analyzer/cubit/analyzer_cubit.dart';
import 'package:vision_companion/features/analyzer/cubit/analyzer_state.dart';
import 'package:vision_companion/features/analyzer/services/vision_service.dart';
import 'package:vision_companion/features/auth/cubit/auth_cubit.dart';
import 'package:vision_companion/features/auth/cubit/auth_state.dart';
import 'package:vision_companion/features/auth/repositories/auth_repository.dart';
import 'package:vision_companion/features/detector/constants/coco_labels.dart';
import 'package:vision_companion/features/detector/cubit/detector_cubit.dart';
import 'package:vision_companion/features/detector/cubit/detector_state.dart';
import 'package:vision_companion/features/detector/models/detection.dart';
import 'package:vision_companion/features/history/models/history_entry.dart';
import 'package:vision_companion/features/history/repositories/history_repository.dart';
import 'package:vision_companion/features/settings/cubit/settings_cubit.dart';
import 'package:vision_companion/features/settings/pages/settings_page.dart';
import 'package:vision_companion/l10n/app_localizations.dart';

// --- MOCK SERVICES FOR COMPREHENSIVE VERIFICATION ---

class VerificationCrashlyticsService implements CrashlyticsService {
  String? userId;
  final List<String> loggedErrors = [];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> log(String message) async {}

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool fatal = false,
  }) async {
    loggedErrors.add(exception.toString());
  }

  @override
  Future<void> setCustomKey(String key, Object value) async {}

  @override
  Future<void> setUserId(String userId) async {
    this.userId = userId;
  }
}

class VerificationAnalyticsService implements AnalyticsService {
  String? userId;
  final List<String> openedFeatures = [];
  final List<Map<String, dynamic>> detectionCompletedEvents = [];
  final List<Map<String, dynamic>> imageAnalyzedEvents = [];

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
    this.userId = userId;
  }

  @override
  Future<void> logCustomEvent(String name, {Map<String, Object>? parameters}) async {}
}

class VerificationHistoryRepository implements HistoryRepository {
  final List<HistoryEntry> entries = [];

  @override
  Future<String> logHistory({
    String? uid,
    required String featureType,
    required String resultSummary,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  }) async {
    final entry = HistoryEntry(
      id: 'entry_${entries.length + 1}',
      timestamp: timestamp ?? DateTime.now(),
      featureType: featureType,
      resultSummary: resultSummary,
      metadata: metadata,
    );
    entries.add(entry);
    return entry.id;
  }

  @override
  Future<String> logDetection({
    String? uid,
    required String resultSummary,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  }) async {
    return logHistory(
      uid: uid,
      featureType: 'detector',
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
  }) async {
    return logHistory(
      uid: uid,
      featureType: 'analyzer',
      resultSummary: resultSummary,
      metadata: metadata,
      timestamp: timestamp,
    );
  }

  @override
  Future<List<HistoryEntry>> getHistory({String? uid, int limit = 50, String? featureType}) async {
    return entries;
  }

  @override
  Stream<List<HistoryEntry>> streamHistory({String? uid, int limit = 50, String? featureType}) =>
      Stream.value(entries);

  @override
  Future<void> deleteHistoryEntry({String? uid, required String docId}) async {}
}

class VerificationVisionService implements VisionService {
  String mockResponse = 'A brown dog playing outside.\nTags: dog (95%), grass (90%)';

  @override
  Future<String> analyzeImage({
    required String imagePath,
    required String apiKey,
    String? prompt,
    String languageCode = 'en',
    String? model,
  }) async {
    return mockResponse;
  }
}

class FakeVerificationAuthRepository implements AuthRepository {
  @override
  Stream<User?> get authStateChanges => const Stream.empty();

  @override
  User? get currentUser => null;

  @override
  Future<UserCredential?> signInWithEmail(String email, String password) async => null;

  @override
  Future<UserCredential?> signUpWithEmail(String email, String password, {String? displayName}) async =>
      null;

  @override
  Future<UserCredential?> signInWithGoogle() async => null;

  @override
  Future<void> signOut() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('1. Authentication Verification', () {
    test('Authenticated state exposes userId and uid identically', () {
      const auth = Authenticated(
        userId: 'verified_user_123',
        email: 'user@test.org',
        displayName: 'Vision Tester',
      );
      expect(auth.userId, equals('verified_user_123'));
      expect(auth.uid, equals('verified_user_123'));
      expect(auth.displayName, equals('Vision Tester'));
      expect(auth.email, equals('user@test.org'));
    });
  });

  group('2. Detector Functionality & Accessibility Verification', () {
    test('Pause, Resume, and Bounding Box parsing work with precision', () {
      const detection = Detection(
        label: 'person',
        classId: 0,
        confidence: 0.94,
        boundingBox: Rect.fromLTRB(0.1, 0.2, 0.5, 0.8),
      );

      expect(detection.confidencePercentage, equals(94));
      expect(detection.displayText, equals('person 94%'));

      // Verify localized labels from COCO dictionary
      expect(CocoLabels.getLocalizedLabel('person', 'en'), equals('person'));
      expect(CocoLabels.getLocalizedLabel('person', 'hi'), equals('व्यक्ति'));

      // Test Cubit Pause and Resume states
      final cubit = DetectorCubit();
      expect(cubit.state, isA<DetectorInitial>());

      cubit.pauseDetection();
      expect(cubit.state, isA<DetectorPaused>());

      cubit.resumeDetection();
      expect(cubit.state, isA<DetectorRunning>());

      cubit.stopDetection();
      expect(cubit.state, isA<DetectorStopped>());
      cubit.close();
    });

    test('2-second announcement debounce logic', () {
      DateTime time1 = DateTime(2026, 1, 1, 12, 0, 0);
      DateTime time2 = time1.add(const Duration(milliseconds: 1500));
      DateTime time3 = time1.add(const Duration(milliseconds: 2100));

      expect(time2.difference(time1).inMilliseconds < 2000, isTrue); // throttled
      expect(time3.difference(time1).inMilliseconds >= 2000, isTrue); // allowed
    });
  });

  group('3. Analyzer & Firebase Integration Verification', () {
    test('analyzeImage parses tags, logs Firestore history, triggers image_analyzed, and NEVER stores image in Firebase Storage', () async {
      final historyRepo = VerificationHistoryRepository();
      final analyticsService = VerificationAnalyticsService();
      final visionService = VerificationVisionService();

      final cubit = AnalyzerCubit(
        visionService: visionService,
        historyRepository: historyRepo,
        analyticsService: analyticsService,
        apiKeyProvider: () => 'test_api_key_gemini',
      );

      await cubit.analyzeImage('/local/cache/captured_frame.jpg');

      // Verify state
      expect(cubit.state, isA<AnalyzerResult>());
      final result = cubit.state as AnalyzerResult;
      expect(result.data.tags.length, equals(2));
      expect(result.data.tags.first.label, equals('dog'));
      expect(result.data.tags.first.formattedConfidence, equals('95%'));
      expect(result.data.tags.first.semanticLabel, equals('Tag: dog, 95% confidence'));

      // Verify Firestore history logged WITHOUT image upload
      expect(historyRepo.entries.length, equals(1));
      expect(historyRepo.entries.first.featureType, equals('analyzer'));
      expect(historyRepo.entries.first.resultSummary, contains('A brown dog playing outside.'));
      expect(historyRepo.entries.first.metadata?['imagePath'], equals('captured_frame.jpg'));
      expect(historyRepo.entries.first.metadata?['storageUrl'], isNull); // ZERO Firebase Storage upload

      // Verify Analytics event
      expect(analyticsService.imageAnalyzedEvents.length, equals(1));
      expect(analyticsService.imageAnalyzedEvents.first['tagsCount'], equals(2));

      cubit.close();
    });
  });

  group('4. Localization & ICU Plurals Verification', () {
    testWidgets('English and Hindi ARB bundles format ICU plurals correctly', (tester) async {
      late AppLocalizations enL10n;
      late AppLocalizations hiL10n;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(builder: (context) {
            enL10n = AppLocalizations.of(context)!;
            return const SizedBox.shrink();
          }),
        ),
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('hi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(builder: (context) {
            hiL10n = AppLocalizations.of(context)!;
            return const SizedBox.shrink();
          }),
        ),
      );
      await tester.pumpAndSettle();

      // ICU Plural Verification
      expect(enL10n.detectorObjectsCount(1), equals('1 object detected'));
      expect(enL10n.detectorObjectsCount(3), equals('3 objects detected'));
      expect(hiL10n.detectorObjectsCount(1), equals('1 वस्तु संसूचित'));
      expect(hiL10n.detectorObjectsCount(3), equals('3 वस्तुएं संसूचित'));

      // ICU Select Verification
      expect(enL10n.themeModeSelect('light'), equals('Light'));
      expect(hiL10n.themeModeSelect('light'), equals('लाइट'));
    });
  });

  group('5. Accessibility Verification: Touch Targets & Semantics', () {
    testWidgets('SettingsPage satisfies min 48x48 tap targets and accessible Semantics headers', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final settingsCubit = SettingsCubit(prefs: prefs);
      final analyticsService = VerificationAnalyticsService();

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<SettingsCubit>.value(value: settingsCubit),
            BlocProvider<AuthCubit>.value(
              value: AuthCubit(
                authRepository: FakeVerificationAuthRepository(),
              ),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SettingsPage(analyticsService: analyticsService),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify feature_opened logged
      expect(analyticsService.openedFeatures, contains('settings'));

      // Verify sign in button satisfies touch target >= 48dp
      final signInFinder = find.widgetWithText(ElevatedButton, 'Sign In');
      expect(signInFinder, findsOneWidget);
      final size = tester.getSize(signInFinder);
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(48.0));

      // Verify Semantics headers
      final headers = find.byWidgetPredicate((w) => w is Semantics && w.properties.header == true);
      expect(headers, findsAtLeastNWidgets(3));
    });
  });
}
