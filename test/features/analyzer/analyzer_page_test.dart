import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vision_companion/features/analyzer/cubit/analyzer_cubit.dart';
import 'package:vision_companion/features/analyzer/cubit/analyzer_state.dart';
import 'package:vision_companion/features/analyzer/models/analysis_data.dart';
import 'package:vision_companion/features/analyzer/pages/analyzer_page.dart';
import 'package:vision_companion/features/settings/cubit/settings_cubit.dart';
import 'package:vision_companion/features/settings/cubit/settings_state.dart';
import 'package:vision_companion/l10n/app_localizations.dart';

class MockAnalyzerCubit extends Cubit<AnalyzerState> implements AnalyzerCubit {
  MockAnalyzerCubit(super.initialState);

  bool retryCalled = false;
  bool resetCalled = false;
  String? lastAnalyzedPath;

  @override
  Future<void> analyzeImage(
    String imagePath, {
    String? prompt,
    String? apiKeyOverride,
    String languageCode = 'en',
    String? model,
  }) async {
    lastAnalyzedPath = imagePath;
    emit(AnalyzerProcessing(imagePath: imagePath));
  }

  @override
  Future<void> retry({String? apiKeyOverride, String languageCode = 'en'}) async {
    retryCalled = true;
    emit(const AnalyzerProcessing(imagePath: 'test_path.jpg'));
  }

  @override
  void reset() {
    resetCalled = true;
    emit(const AnalyzerIdle());
  }

  @override
  void init() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockSettingsCubit extends Cubit<SettingsState> implements SettingsCubit {
  MockSettingsCubit(super.initialState);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget buildTestableAnalyzerPage({
  required AnalyzerCubit analyzerCubit,
  required SettingsCubit settingsCubit,
  Locale locale = const Locale('en'),
}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<AnalyzerCubit>.value(value: analyzerCubit),
      BlocProvider<SettingsCubit>.value(value: settingsCubit),
    ],
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
      ],
      home: const AnalyzerPage(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AnalyzerPage Widget & Accessibility Tests', () {
    testWidgets('Renders camera placeholder and enabled capture button in Idle state', (tester) async {
      final analyzerCubit = MockAnalyzerCubit(const AnalyzerIdle());
      final settingsCubit = MockSettingsCubit(const SettingsState(locale: Locale('en'), themeMode: ThemeMode.light));

      await tester.pumpWidget(buildTestableAnalyzerPage(
        analyzerCubit: analyzerCubit,
        settingsCubit: settingsCubit,
      ));
      await tester.pumpAndSettle();

      // Title must be displayed
      expect(find.text('AI Scene Analyzer'), findsOneWidget);

      // Camera placeholder displayed when hardware camera uninitialized in test
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);

      // Capture button must be enabled in Idle state
      final captureBtnFinder = find.byType(ElevatedButton);
      expect(captureBtnFinder, findsOneWidget);
      final ElevatedButton captureBtn = tester.widget(captureBtnFinder);
      expect(captureBtn.onPressed, isNotNull);
    });

    testWidgets('Shows spinning progress indicator, announces processing, and disables capture button during Processing', (tester) async {
      final analyzerCubit = MockAnalyzerCubit(const AnalyzerProcessing(imagePath: 'test_image.jpg'));
      final settingsCubit = MockSettingsCubit(const SettingsState(locale: Locale('en'), themeMode: ThemeMode.light));

      await tester.pumpWidget(buildTestableAnalyzerPage(
        analyzerCubit: analyzerCubit,
        settingsCubit: settingsCubit,
      ));
      await tester.pump();

      // Spinning progress indicator must be displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Analyzing image with AI...'), findsOneWidget);

      // Semantics label 'processing' must be present for TalkBack
      expect(
        find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'processing'),
        findsOneWidget,
      );

      // Capture button must be disabled while processing
      final captureBtnFinder = find.byType(ElevatedButton);
      expect(captureBtnFinder, findsOneWidget);
      final ElevatedButton captureBtn = tester.widget(captureBtnFinder);
      expect(captureBtn.onPressed, isNull);
    });

    testWidgets('Displays AI description, Result chips with TalkBack semantics, and Take Another Photo button in Result state', (tester) async {
      final analysisData = AnalysisData(
        description: 'A brown cat sitting quietly on a couch.',
        imagePath: 'cat.jpg',
        model: 'gemini-1.5-flash',
        latencyMs: 142,
        timestamp: DateTime.now(),
        tags: const [
          AnalysisTag(label: 'cat', confidence: 0.94),
          AnalysisTag(label: 'furniture', confidence: 0.90),
        ],
      );

      final analyzerCubit = MockAnalyzerCubit(AnalyzerResult(analysisData));
      final settingsCubit = MockSettingsCubit(const SettingsState(locale: Locale('en'), themeMode: ThemeMode.light));

      await tester.pumpWidget(buildTestableAnalyzerPage(
        analyzerCubit: analyzerCubit,
        settingsCubit: settingsCubit,
      ));
      await tester.pumpAndSettle();

      // Description is displayed
      expect(find.text('A brown cat sitting quietly on a couch.'), findsOneWidget);
      expect(find.text('Scene Description'), findsOneWidget);
      expect(find.text('142ms'), findsOneWidget);

      // Result chips with confidence semantics: e.g. "Tag: cat, 94% confidence"
      expect(find.bySemanticsLabel('Tag: cat, 94% confidence'), findsOneWidget);
      expect(find.text('cat • 94%'), findsOneWidget);
      expect(find.bySemanticsLabel('Tag: furniture, 90% confidence'), findsOneWidget);

      // Take Another Photo button is displayed
      expect(find.text('Take Another Photo'), findsOneWidget);

      // Tap Take Another Photo
      await tester.tap(find.text('Take Another Photo'));
      expect(analyzerCubit.resetCalled, isTrue);
    });

    testWidgets('Displays friendly error and Retry button in Error state, and retry invokes cubit', (tester) async {
      final analyzerCubit = MockAnalyzerCubit(
        const AnalyzerError(
          'Unable to analyze image. Please check your internet connection and try again.',
          failedImagePath: 'failed_image.jpg',
        ),
      );
      final settingsCubit = MockSettingsCubit(const SettingsState(locale: Locale('en'), themeMode: ThemeMode.light));

      await tester.pumpWidget(buildTestableAnalyzerPage(
        analyzerCubit: analyzerCubit,
        settingsCubit: settingsCubit,
      ));
      await tester.pumpAndSettle();

      // Error message displayed
      expect(
        find.text('Unable to analyze image. Please check your internet connection and try again.'),
        findsOneWidget,
      );

      // Retry button is displayed
      expect(find.text('Retry'), findsOneWidget);

      // Tap Retry button
      await tester.tap(find.text('Retry'));
      expect(analyzerCubit.retryCalled, isTrue);
    });

    testWidgets('Localizes UI in Hindi locale', (tester) async {
      final analyzerCubit = MockAnalyzerCubit(const AnalyzerIdle());
      final settingsCubit = MockSettingsCubit(const SettingsState(locale: Locale('hi'), themeMode: ThemeMode.light));

      await tester.pumpWidget(buildTestableAnalyzerPage(
        analyzerCubit: analyzerCubit,
        settingsCubit: settingsCubit,
        locale: const Locale('hi'),
      ));
      await tester.pumpAndSettle();

      // Hindi Title
      expect(find.text('AI दृश्य विश्लेषक'), findsOneWidget);

      // Hindi Capture Button
      expect(find.text('फोटो खींचें'), findsOneWidget);
    });
  });
}
