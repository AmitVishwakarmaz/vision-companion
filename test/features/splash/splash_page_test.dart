import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vision_companion/core/constants/app_constants.dart';
import 'package:vision_companion/core/di/injection_container.dart';
import 'package:vision_companion/core/router/app_router.dart';
import 'package:vision_companion/features/auth/cubit/auth_cubit.dart';
import 'package:vision_companion/features/auth/repositories/auth_repository.dart';
import 'package:vision_companion/features/settings/cubit/settings_cubit.dart';
import 'package:vision_companion/features/splash/pages/splash_page.dart';
import 'package:vision_companion/l10n/app_localizations.dart';

class StubAuthRepository implements AuthRepository {
  @override
  Stream<User?> get authStateChanges => const Stream.empty();

  @override
  User? get currentUser => null;

  @override
  Future<UserCredential?> signInWithEmail(String email, String password) async => null;

  @override
  Future<UserCredential?> signUpWithEmail(String email, String password, {String? displayName}) async => null;

  @override
  Future<UserCredential?> signInWithGoogle() async => null;

  @override
  Future<void> signOut() async {}
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await sl.reset();
    await initDependencies(authRepository: StubAuthRepository());
  });

  tearDown(() async {
    await sl.reset();
    AppRouter.reset();
  });

  Widget buildTestWidget() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: sl<AuthCubit>()),
        BlocProvider<SettingsCubit>.value(value: sl<SettingsCubit>()),
      ],
      child: BlocBuilder<SettingsCubit, dynamic>(
        builder: (context, _) {
          final locale = context.read<SettingsCubit>().state.locale;
          return MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SplashPage(),
          );
        },
      ),
    );
  }

  testWidgets('SplashPage renders branding, language choices, and continue button',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Verify title and subtitle
    expect(find.text('Vision Companion'), findsWidgets);
    expect(find.text('AI Assistive Companion'), findsOneWidget);

    // Verify both language options are rendered
    expect(find.text('English'), findsOneWidget);
    expect(find.text('हिन्दी (Hindi)'), findsOneWidget);

    // Verify Continue button
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('Tapping Hindi changes language and updates UI dynamically',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Tap Hindi language card
    await tester.tap(find.text('हिन्दी (Hindi)'));
    await tester.pumpAndSettle();

    // Verify SettingsCubit state updated to Hindi
    expect(sl<SettingsCubit>().state.locale.languageCode, equals(AppConstants.localeHi));

    // Verify UI reflects Hindi localization
    expect(find.text('विज़न कम्पेनियन'), findsWidgets);
    expect(find.text('आगे बढ़ें'), findsOneWidget);
  });

  testWidgets('Language selection cards and Continue button satisfy touch target constraints',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Verify Continue button height >= 48 dp
    final continueButton = tester.getRect(find.widgetWithText(ElevatedButton, 'Continue'));
    expect(continueButton.height, greaterThanOrEqualTo(48.0));

    // Verify English card touch target >= 48 dp
    final englishCard = tester.getRect(find.widgetWithText(InkWell, 'English'));
    expect(englishCard.height, greaterThanOrEqualTo(48.0));

    // Verify Hindi card touch target >= 48 dp
    final hindiCard = tester.getRect(find.widgetWithText(InkWell, 'हिन्दी (Hindi)'));
    expect(hindiCard.height, greaterThanOrEqualTo(48.0));
  });
}
