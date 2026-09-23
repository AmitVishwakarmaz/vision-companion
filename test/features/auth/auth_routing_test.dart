import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vision_companion/core/constants/app_constants.dart';
import 'package:vision_companion/core/di/injection_container.dart';
import 'package:vision_companion/core/router/app_router.dart';
import 'package:vision_companion/features/auth/cubit/auth_cubit.dart';
import 'package:vision_companion/features/auth/cubit/auth_state.dart';
import 'package:vision_companion/features/auth/repositories/auth_repository.dart';
import 'package:vision_companion/features/settings/cubit/settings_cubit.dart';
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
    SharedPreferences.setMockInitialValues({
      AppConstants.prefHasSelectedLanguage: true,
    });
    await sl.reset();
    await initDependencies(authRepository: StubAuthRepository());
  });

  tearDown(() async {
    await sl.reset();
    AppRouter.reset();
  });

  testWidgets('Unauthenticated user is redirected from home to /login',
      (WidgetTester tester) async {
    final authCubit = sl<AuthCubit>();
    // Verify cubit is unauthenticated
    expect(authCubit.state, isA<Unauthenticated>());

    final router = AppRouter.createRouter(
      authCubit,
      initialLocation: AppConstants.routeHome,
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: authCubit),
          BlocProvider<SettingsCubit>.value(value: sl<SettingsCubit>()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify user was redirected to Login screen
    expect(find.text('Sign In'), findsWidgets);
    expect(router.routeInformationProvider.value.uri.path, equals(AppConstants.routeLogin));
  });

  testWidgets('Unauthenticated user cannot access protected routes like /detector',
      (WidgetTester tester) async {
    final authCubit = sl<AuthCubit>();
    final router = AppRouter.createRouter(
      authCubit,
      initialLocation: AppConstants.routeHome,
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: authCubit),
          BlocProvider<SettingsCubit>.value(value: sl<SettingsCubit>()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Attempt navigating to protected detector route
    router.go(AppConstants.routeDetector);
    await tester.pumpAndSettle();

    // Verify redirected back to /login
    expect(router.routeInformationProvider.value.uri.path, equals(AppConstants.routeLogin));
    expect(find.text('Sign In'), findsWidgets);
  });

  testWidgets('App opens on splash screen when language is not yet selected',
      (WidgetTester tester) async {
    await sl<SharedPreferences>().setBool(AppConstants.prefHasSelectedLanguage, false);

    final authCubit = sl<AuthCubit>();
    final router = AppRouter.createRouter(authCubit);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: authCubit),
          BlocProvider<SettingsCubit>.value(value: sl<SettingsCubit>()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify app starts at /splash with language selection
    expect(router.routeInformationProvider.value.uri.path, equals(AppConstants.routeSplash));
    expect(find.text('Vision Companion'), findsWidgets);
    expect(find.text('English'), findsWidgets);
    expect(find.text('हिन्दी (Hindi)'), findsWidgets);
  });

  testWidgets('App skips splash and opens login directly when language is already selected',
      (WidgetTester tester) async {
    final authCubit = sl<AuthCubit>();
    final router = AppRouter.createRouter(authCubit);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: authCubit),
          BlocProvider<SettingsCubit>.value(value: sl<SettingsCubit>()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify app skips splash and goes straight to /login
    expect(router.routeInformationProvider.value.uri.path, equals(AppConstants.routeLogin));
    expect(find.text('Sign In'), findsWidgets);
  });
}
