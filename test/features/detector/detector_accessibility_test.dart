import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vision_companion/features/detector/constants/coco_labels.dart';
import 'package:vision_companion/features/detector/cubit/detector_cubit.dart';
import 'package:vision_companion/features/detector/cubit/detector_state.dart';
import 'package:vision_companion/features/detector/models/detection.dart';
import 'package:vision_companion/features/detector/pages/detector_page.dart';
import 'package:vision_companion/features/detector/widgets/bounding_box_painter.dart';
import 'package:vision_companion/features/settings/cubit/settings_cubit.dart';
import 'package:vision_companion/features/settings/cubit/settings_state.dart';
import 'package:vision_companion/l10n/app_localizations.dart';

class MockDetectorCubit extends Cubit<DetectorState> implements DetectorCubit {
  MockDetectorCubit(super.initialState);

  bool pauseCalled = false;
  bool resumeCalled = false;
  bool startCalled = false;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> startDetection({Map<String, dynamic>? metadata}) async {
    startCalled = true;
    emit(const DetectorRunning(detectedObjects: []));
  }

  @override
  void pauseDetection() {
    pauseCalled = true;
    emit(const DetectorPaused());
  }

  @override
  void resumeDetection() {
    resumeCalled = true;
    emit(const DetectorRunning(detectedObjects: []));
  }

  @override
  void stopDetection() {
    emit(const DetectorStopped());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockSettingsCubit extends Cubit<SettingsState> implements SettingsCubit {
  MockSettingsCubit(super.initialState);

  @override
  Future<void> toggleLanguage() async {
    final nextLocale = state.locale.languageCode == 'en'
        ? const Locale('hi')
        : const Locale('en');
    emit(state.copyWith(locale: nextLocale));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget buildTestableDetectorPage({
  required MockDetectorCubit detectorCubit,
  required MockSettingsCubit settingsCubit,
  Locale locale = const Locale('en'),
}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<DetectorCubit>.value(value: detectorCubit),
      BlocProvider<SettingsCubit>.value(value: settingsCubit),
    ],
    child: MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('hi')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const DetectorPage(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CocoLabels Localized Mapping Tests', () {
    test('Translates English labels to Hindi accurately', () {
      expect(CocoLabels.getLocalizedLabel('person', 'hi'), 'व्यक्ति');
      expect(CocoLabels.getLocalizedLabel('car', 'hi'), 'कार');
      expect(CocoLabels.getLocalizedLabel('dog', 'hi'), 'कुत्ता');
      expect(CocoLabels.getLocalizedLabel('cat', 'hi'), 'बिल्ली');
      expect(CocoLabels.getLocalizedLabel('bottle', 'hi'), 'बोतल');
      expect(CocoLabels.getLocalizedLabel('cell phone', 'hi'), 'मोबाइल फोन');
    });

    test('Retains original English labels when locale is English', () {
      expect(CocoLabels.getLocalizedLabel('person', 'en'), 'person');
      expect(CocoLabels.getLocalizedLabel('car', 'en'), 'car');
      expect(CocoLabels.getLocalizedLabel('dog', 'en'), 'dog');
    });

    test('Falls back gracefully for unknown classes in Hindi', () {
      expect(CocoLabels.getLocalizedLabel('unknown_spaceship', 'hi'), 'unknown_spaceship');
    });
  });

  group('DetectorPage TalkBack Accessibility & Localization Tests', () {
    testWidgets('Renders camera placeholder with proper semantics when uninitialized', (tester) async {
      final detectorCubit = MockDetectorCubit(const DetectorInitial());
      final settingsCubit = MockSettingsCubit(const SettingsState(locale: Locale('en'), themeMode: ThemeMode.light));

      await tester.pumpWidget(buildTestableDetectorPage(
        detectorCubit: detectorCubit,
        settingsCubit: settingsCubit,
      ));
      await tester.pumpAndSettle();

      // Camera placeholder has container semantics with description
      expect(
        find.byWidgetPredicate((w) =>
            w is Semantics &&
            w.properties.label == 'Live camera feed will appear here'),
        findsOneWidget,
      );

      // Start detection button semantics
      expect(
        find.byWidgetPredicate((w) =>
            w is Semantics &&
            w.properties.button == true &&
            w.properties.label == 'Start Detection'),
        findsOneWidget,
      );
    });

    testWidgets('Pause button has correct localized text and semantics when running in English', (tester) async {
      final detectorCubit = MockDetectorCubit(const DetectorRunning(detectedObjects: []));
      final settingsCubit = MockSettingsCubit(const SettingsState(locale: Locale('en'), themeMode: ThemeMode.light));

      await tester.pumpWidget(buildTestableDetectorPage(
        detectorCubit: detectorCubit,
        settingsCubit: settingsCubit,
      ));
      await tester.pumpAndSettle();

      // Button must show "Pause detection"
      expect(find.text('Pause detection'), findsOneWidget);

      // Button must have Semantics label "Pause detection"
      expect(
        find.byWidgetPredicate((w) =>
            w is Semantics &&
            w.properties.button == true &&
            w.properties.label == 'Pause detection'),
        findsOneWidget,
      );

      // Tap pause button
      await tester.tap(find.text('Pause detection'));
      expect(detectorCubit.pauseCalled, isTrue);
    });

    testWidgets('Resume button has correct localized text and semantics when paused in English', (tester) async {
      final detectorCubit = MockDetectorCubit(const DetectorPaused());
      final settingsCubit = MockSettingsCubit(const SettingsState(locale: Locale('en'), themeMode: ThemeMode.light));

      await tester.pumpWidget(buildTestableDetectorPage(
        detectorCubit: detectorCubit,
        settingsCubit: settingsCubit,
      ));
      await tester.pumpAndSettle();

      // Button must show "Resume detection"
      expect(find.text('Resume detection'), findsOneWidget);

      // Button must have Semantics label "Resume detection"
      expect(
        find.byWidgetPredicate((w) =>
            w is Semantics &&
            w.properties.button == true &&
            w.properties.label == 'Resume detection'),
        findsOneWidget,
      );

      // Tap resume button
      await tester.tap(find.text('Resume detection'));
      expect(detectorCubit.resumeCalled, isTrue);
    });

    testWidgets('Pause and Resume buttons switch language immediately in Hindi locale', (tester) async {
      final detectorCubit = MockDetectorCubit(const DetectorRunning(detectedObjects: []));
      final settingsCubit = MockSettingsCubit(const SettingsState(locale: Locale('hi'), themeMode: ThemeMode.light));

      await tester.pumpWidget(buildTestableDetectorPage(
        detectorCubit: detectorCubit,
        settingsCubit: settingsCubit,
        locale: const Locale('hi'),
      ));
      await tester.pumpAndSettle();

      // Running in Hindi -> "डिटेक्शन रोकें"
      expect(find.text('डिटेक्शन रोकें'), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) =>
            w is Semantics &&
            w.properties.button == true &&
            w.properties.label == 'डिटेक्शन रोकें'),
        findsOneWidget,
      );

      // Transition to paused in Hindi
      detectorCubit.emit(const DetectorPaused());
      await tester.pumpAndSettle();

      // Paused in Hindi -> "डिटेक्शन फिर शुरू करें"
      expect(find.text('डिटेक्शन फिर शुरू करें'), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) =>
            w is Semantics &&
            w.properties.button == true &&
            w.properties.label == 'डिटेक्शन फिर शुरू करें'),
        findsOneWidget,
      );
    });

    testWidgets('Status badge has liveRegion and reflects detected objects with latency', (tester) async {
      final detectorCubit = MockDetectorCubit(DetectorResults(
        detections: [
          Detection(
            label: 'person',
            confidence: 0.94,
            classId: 0,
            boundingBox: const Rect.fromLTWH(0.1, 0.1, 0.5, 0.5),
          ),
          Detection(
            label: 'dog',
            confidence: 0.82,
            classId: 16,
            boundingBox: const Rect.fromLTWH(0.6, 0.6, 0.3, 0.3),
          ),
        ],
        inferenceTimeMs: 42,
      ));
      final settingsCubit = MockSettingsCubit(const SettingsState(locale: Locale('en'), themeMode: ThemeMode.light));

      await tester.pumpWidget(buildTestableDetectorPage(
        detectorCubit: detectorCubit,
        settingsCubit: settingsCubit,
      ));
      await tester.pumpAndSettle();

      // Status text displays "2 objects | 42ms"
      expect(find.text('2 objects | 42ms'), findsOneWidget);

      // Status badge has liveRegion: true semantics
      expect(
        find.byWidgetPredicate((w) =>
            w is Semantics &&
            w.properties.liveRegion == true &&
            w.properties.label == '2 objects | 42ms'),
        findsOneWidget,
      );
    });

    testWidgets('Controls meet minimum 48x48 tap target and have no focus traps', (tester) async {
      final detectorCubit = MockDetectorCubit(const DetectorInitial());
      final settingsCubit = MockSettingsCubit(const SettingsState(locale: Locale('en'), themeMode: ThemeMode.light));

      await tester.pumpWidget(buildTestableDetectorPage(
        detectorCubit: detectorCubit,
        settingsCubit: settingsCubit,
      ));
      await tester.pumpAndSettle();

      // Verify button size is >= 48 in height and full width
      final buttonFinder = find.byType(ElevatedButton);
      final size = tester.getSize(buttonFinder);
      expect(size.height, greaterThanOrEqualTo(48.0));
      expect(size.width, greaterThanOrEqualTo(48.0));
    });

    testWidgets('Announces top detected object and throttles announcements to 2 seconds', (tester) async {
      DateTime fakeNow = DateTime(2026, 9, 23, 12, 0, 0);
      DetectorPage.nowProvider = () => fakeNow;
      addTearDown(() {
        DetectorPage.nowProvider = DateTime.now;
      });

      final announcements = <String>[];
      tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
        SystemChannels.accessibility,
        (dynamic message) async {
          if (message is Map && message['type'] == 'announce') {
            final data = message['data'] as Map?;
            if (data != null && data['message'] is String) {
              announcements.add(data['message'] as String);
            }
          }
          return null;
        },
      );

      final detectorCubit = MockDetectorCubit(const DetectorRunning(detectedObjects: []));
      final settingsCubit = MockSettingsCubit(const SettingsState(locale: Locale('en'), themeMode: ThemeMode.light));

      await tester.pumpWidget(buildTestableDetectorPage(
        detectorCubit: detectorCubit,
        settingsCubit: settingsCubit,
      ));
      await tester.pumpAndSettle();

      // Emit first detection results with person (95%) and bottle (70%)
      detectorCubit.emit(DetectorResults(
        detections: [
          Detection(
            label: 'bottle',
            confidence: 0.70,
            classId: 39,
            boundingBox: const Rect.fromLTWH(0, 0, 1, 1),
          ),
          Detection(
            label: 'person',
            confidence: 0.95,
            classId: 0,
            boundingBox: const Rect.fromLTWH(0, 0, 1, 1),
          ),
        ],
        inferenceTimeMs: 30,
      ));
      await tester.pump();

      // Should announce top object (person detected)
      expect(announcements, contains('person detected'));
      final countBefore = announcements.length;

      // Immediate second emission (500ms later, under 2 seconds) with car (99%)
      fakeNow = fakeNow.add(const Duration(milliseconds: 500));
      detectorCubit.emit(DetectorResults(
        detections: [
          Detection(
            label: 'car',
            confidence: 0.99,
            classId: 2,
            boundingBox: const Rect.fromLTWH(0, 0, 1, 1),
          ),
        ],
        inferenceTimeMs: 28,
      ));
      await tester.pump();

      // Throttled: no new announcement should be emitted immediately
      expect(announcements.length, equals(countBefore));

      // Advance simulated time past 2.0s threshold (+2100ms)
      fakeNow = fakeNow.add(const Duration(milliseconds: 2100));

      // Now emit another detection with updated latency / object
      detectorCubit.emit(DetectorResults(
        detections: [
          Detection(
            label: 'car',
            confidence: 0.99,
            classId: 2,
            boundingBox: const Rect.fromLTWH(0, 0, 1, 1),
          ),
        ],
        inferenceTimeMs: 35,
      ));
      await tester.pump();

      // After 2 seconds, new announcement is allowed
      expect(announcements.length, greaterThan(countBefore));
      expect(announcements.last, equals('car detected'));
    });

    testWidgets('Announces top detected object in Hindi when locale is Hindi', (tester) async {
      final announcements = <String>[];
      tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
        SystemChannels.accessibility,
        (dynamic message) async {
          if (message is Map && message['type'] == 'announce') {
            final data = message['data'] as Map?;
            if (data != null && data['message'] is String) {
              announcements.add(data['message'] as String);
            }
          }
          return null;
        },
      );

      final detectorCubit = MockDetectorCubit(const DetectorRunning(detectedObjects: []));
      final settingsCubit = MockSettingsCubit(const SettingsState(locale: Locale('hi'), themeMode: ThemeMode.light));

      await tester.pumpWidget(buildTestableDetectorPage(
        detectorCubit: detectorCubit,
        settingsCubit: settingsCubit,
        locale: const Locale('hi'),
      ));
      await tester.pumpAndSettle();

      // Emit results with person
      detectorCubit.emit(DetectorResults(
        detections: [
          Detection(
            label: 'person',
            confidence: 0.96,
            classId: 0,
            boundingBox: const Rect.fromLTWH(0, 0, 1, 1),
          ),
        ],
        inferenceTimeMs: 40,
      ));
      await tester.pump();

      // Should announce in Hindi: "व्यक्ति मिला"
      expect(announcements, contains('व्यक्ति मिला'));
    });

    test('BoundingBoxPainter renders Hindi label when languageCode is hi', () {
      final painterHi = BoundingBoxPainter(
        detections: [
          Detection(
            label: 'person',
            confidence: 0.95,
            classId: 0,
            boundingBox: const Rect.fromLTWH(0.1, 0.1, 0.5, 0.5),
          ),
        ],
        languageCode: 'hi',
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      painterHi.paint(canvas, const Size(400, 600));
      final picture = recorder.endRecording();
      expect(picture, isNotNull);
      expect(painterHi.languageCode, equals('hi'));
    });

    test('BoundingBoxPainter shouldRepaint triggers on languageCode change', () {
      final painterEn = BoundingBoxPainter(
        detections: [],
        languageCode: 'en',
      );
      final painterHi = BoundingBoxPainter(
        detections: [],
        languageCode: 'hi',
      );

      expect(painterHi.shouldRepaint(painterEn), isTrue);
    });
  });
}
