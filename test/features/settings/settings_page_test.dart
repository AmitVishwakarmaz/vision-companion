import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vision_companion/core/services/analytics_service.dart';
import 'package:vision_companion/core/services/crashlytics_service.dart';
import 'package:vision_companion/features/auth/cubit/auth_cubit.dart';
import 'package:vision_companion/features/auth/cubit/auth_state.dart';
import 'package:vision_companion/features/settings/cubit/settings_cubit.dart';
import 'package:vision_companion/features/settings/cubit/settings_state.dart';
import 'package:vision_companion/features/settings/pages/settings_page.dart';
import 'package:vision_companion/l10n/app_localizations.dart';

class MockSettingsAnalyticsService implements AnalyticsService {
  final List<String> openedFeatures = [];

  @override
  Future<void> logFeatureOpened(String featureName) async {
    openedFeatures.add(featureName);
  }

  @override
  Future<void> logDetectionCompleted({
    required int count,
    required List<String> categories,
    int? latencyMs,
  }) async {}

  @override
  Future<void> logImageAnalyzed({
    String? model,
    int? latencyMs,
    int? tagsCount,
  }) async {}

  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> logCustomEvent(String name, {Map<String, Object>? parameters}) async {}
}

class MockSettingsAuthCubit extends Cubit<AuthState> implements AuthCubit {
  bool signOutCalled = false;

  MockSettingsAuthCubit([AuthState? initial]) : super(initial ?? const Unauthenticated());

  @override
  CrashlyticsService? get crashlyticsService => null;

  @override
  AnalyticsService? get analyticsService => null;

  @override
  Future<void> signInWithEmail(String email, String password) async {}

  @override
  Future<void> signUpWithEmail(String email, String password, {String? displayName}) async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {
    signOutCalled = true;
    emit(const Unauthenticated());
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late SettingsCubit settingsCubit;
  late MockSettingsAuthCubit authCubit;
  late MockSettingsAnalyticsService mockAnalytics;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    settingsCubit = SettingsCubit(prefs: prefs);
    authCubit = MockSettingsAuthCubit();
    mockAnalytics = MockSettingsAnalyticsService();
  });

  Widget buildTestWidget({MockSettingsAuthCubit? customAuthCubit}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>.value(value: settingsCubit),
        BlocProvider<AuthCubit>.value(value: customAuthCubit ?? authCubit),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return MaterialApp(
            locale: state.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SettingsPage(analyticsService: mockAnalytics),
          );
        },
      ),
    );
  }

  group('SettingsPage Event & Accessibility Tests', () {
    testWidgets('Triggers feature_opened analytics event for settings on mount', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(mockAnalytics.openedFeatures, contains('settings'));
    });

    testWidgets('Renders guest profile information, status badge, and accessible sign-in button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Guest labels
      expect(find.text('Guest User'), findsOneWidget);
      expect(find.text('Not signed in'), findsOneWidget);
      expect(find.text('Guest Mode'), findsOneWidget);

      // Sign In button exists with >= 48dp touch target
      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      expect(signInButton, findsOneWidget);
      final size = tester.getSize(signInButton);
      expect(size.height, greaterThanOrEqualTo(48.0));
      expect(size.width, greaterThanOrEqualTo(48.0));
    });

    testWidgets('Renders authenticated user profile, UID, status badge, and sign-out button', (tester) async {
      final authenticatedCubit = MockSettingsAuthCubit(
        const Authenticated(
          userId: 'user_xyz_1234567890',
          email: 'testuser@vision.org',
          displayName: 'Test Explorer',
        ),
      );

      await tester.pumpWidget(buildTestWidget(customAuthCubit: authenticatedCubit));
      await tester.pumpAndSettle();

      // Authenticated labels
      expect(find.text('Test Explorer'), findsOneWidget);
      expect(find.text('testuser@vision.org'), findsOneWidget);
      expect(find.text('Signed In'), findsOneWidget);
      expect(find.textContaining('User ID: user_xyz_1...'), findsOneWidget);

      // Sign Out button
      final signOutFinder = find.widgetWithText(TextButton, 'Sign Out');
      expect(signOutFinder, findsOneWidget);
      final signOutSize = tester.getSize(signOutFinder);
      expect(signOutSize.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('Renders About section with version and crash reporting indicator', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('About'), 100.0);
      await tester.pumpAndSettle();

      expect(find.text('About'), findsOneWidget);
      expect(find.text('Vision Companion'), findsWidgets);
      expect(find.textContaining('Version 1.0.0'), findsOneWidget);
      expect(find.textContaining('Crash reporting active'), findsOneWidget);
    });

    testWidgets('Renders accessible headers with Semantics(header: true)', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify that Section titles are marked as headers
      final semanticsFinder = find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.header == true,
      );
      expect(semanticsFinder, findsAtLeastNWidgets(3));
    });
  });
}
