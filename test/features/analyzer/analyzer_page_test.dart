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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockSettingsCubit extends Cubit<SettingsState> implements SettingsCubit {
  MockSettingsCubit(super.initialState);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget buildTestableAnalyzerPage({
  required MockAnalyzerCubit analyzerCubit,
  required MockSettingsCubit settingsCubit,
  Locale locale = const Locale('en'),
}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<AnalyzerCubit>.value(value: analyzerCubit),
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

      // Verify title
      expect(find.text('AI Scene Analyzer'), findsOneWidget);

      // Verify placeholder
      expect(find.text('Capture or choose an image to analyze'), findsOneWidget);

      // Verify Capture button is enabled
      final captureBtnFinder = find.byType(ElevatedButton);
      expect(captureBtnFinder, findsOneWidget);
      final ElevatedButton captureBtn = tester.widget(captureBtnFinder);
      expect(captureBtn.onPressed, isNotNull);
    });

    testWidgets('Shows spinning progress indicator and disables capture button during Processing', (tester) async {
      final analyzerCubit = MockAnalyzerCubit(const AnalyzerProcessing(imagePath: 'sample.jpg'));
      final settingsCubit = MockSettingsCubit(const SettingsState(locale: Locale('en'), themeMode: ThemeMode.light));

      await tester.pumpWidget(buildTestableAnalyzerPage(
        analyzerCubit: analyzerCubit,
        settingsCubit: settingsCubit,
      ));
      await tester.pump();

      // Spinning progress indicator must be displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Analyzing image with AI...'), findsOneWidget);

      // Capture button must be disabled
      final captureBtnFinder = find.byType(ElevatedButton);
      expect(captureBtnFinder, findsOneWidget);
      final ElevatedButton captureBtn = tester.widget(captureBtnFinder);
      expect(captureBtn.onPressed, isNull);
    });

    testWidgets('Displays AI description and Take Another Photo button in Result state', (tester) async {
      final analysisData = AnalysisData(
        description: 'A brown dog playing with a red ball in a sunny park.',
        imagePath: 'dog.jpg',
        model: 'meta-llama/llama-4-scout-17b-16e-instruct',
        latencyMs: 142,
        timestamp: DateTime.now(),
      );

      final analyzerCubit = MockAnalyzerCubit(AnalyzerResult(analysisData));
      final settingsCubit = MockSettingsCubit(const SettingsState(locale: Locale('en'), themeMode: ThemeMode.light));

      await tester.pumpWidget(buildTestableAnalyzerPage(
        analyzerCubit: analyzerCubit,
        settingsCubit: settingsCubit,
      ));
      await tester.pumpAndSettle();

      // Description is displayed
      expect(find.text('A brown dog playing with a red ball in a sunny park.'), findsOneWidget);
      expect(find.text('Scene Description'), findsOneWidget);
      expect(find.text('142ms'), findsOneWidget);

      // Take Another Photo button is displayed
      expect(find.text('Take Another Photo'), findsOneWidget);

      // Tap Take Another Photo
      await tester.tap(find.text('Take Another Photo'));
      expect(analyzerCubit.resetCalled, isTrue);
    });

    testWidgets('Displays friendly error and Retry button in Error state, and retry invokes cubit', (tester) async {
      final analyzerCubit = MockAnalyzerCubit(
        const AnalyzerError(
          'Network error: Unable to connect to Groq AI service. Please check your internet connection.',
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
        find.text('Network error: Unable to connect to Groq AI service. Please check your internet connection.'),
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
