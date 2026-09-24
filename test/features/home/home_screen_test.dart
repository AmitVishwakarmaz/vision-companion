import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vision_companion/core/di/injection_container.dart';
import 'package:vision_companion/core/router/app_router.dart';
import 'package:vision_companion/features/auth/cubit/auth_cubit.dart';
import 'package:vision_companion/features/auth/repositories/auth_repository.dart';
import 'package:vision_companion/features/home/home_screen.dart';
import 'package:vision_companion/features/settings/cubit/settings_cubit.dart';
import 'package:vision_companion/l10n/app_localizations.dart';

class MockUser extends Fake implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;

  MockUser({
    this.uid = 'alex-id',
    this.email = 'alex@example.com',
    this.displayName = 'alex',
  });
}

class FakeUserCredential extends Fake implements UserCredential {
  @override
  final User? user;

  FakeUserCredential(this.user);
}

class FakeHomeAuthRepository implements AuthRepository {
  final StreamController<User?> _controller = StreamController<User?>.broadcast();
  User? _currentUser;
  bool signedOutCalled = false;

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  User? get currentUser => _currentUser;

  void emitUser(User? user) {
    _currentUser = user;
    _controller.add(user);
  }

  @override
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    final user = MockUser(email: email, displayName: email.split('@').first);
    emitUser(user);
    return FakeUserCredential(user);
  }

  @override
  Future<UserCredential?> signUpWithEmail(String email, String password, {String? displayName}) async {
    final user = MockUser(email: email, displayName: displayName ?? email.split('@').first);
    emitUser(user);
    return FakeUserCredential(user);
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    final user = MockUser(email: 'google@example.com', displayName: 'Google User');
    emitUser(user);
    return FakeUserCredential(user);
  }

  @override
  Future<void> signOut() async {
    signedOutCalled = true;
    emitUser(null);
  }

  void dispose() {
    _controller.close();
  }
}

void main() {
  late FakeHomeAuthRepository fakeRepo;
  late AuthCubit authCubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await sl.reset();
    AppRouter.reset();

    fakeRepo = FakeHomeAuthRepository();
    authCubit = AuthCubit(authRepository: fakeRepo);

    await initDependencies(
      authRepository: fakeRepo,
    );
  });

  tearDown(() async {
    await authCubit.close();
    fakeRepo.dispose();
    await sl.reset();
    AppRouter.reset();
  });

  Widget buildTestWidget({required AuthCubit cubit, GoRouter? router}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: cubit),
        BlocProvider<SettingsCubit>.value(value: sl<SettingsCubit>()),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomeScreen(),
      ),
    );
  }

  testWidgets('Renders greeting, profile avatar, and exactly two feature cards',
      (WidgetTester tester) async {
    // Authenticate user with display name
    await authCubit.signInWithEmail('alex@example.com', 'password');

    await tester.pumpWidget(buildTestWidget(cubit: authCubit));
    await tester.pumpAndSettle();

    // 1. Verify greeting
    expect(find.text('Hello, alex!'), findsOneWidget);

    // 2. Verify exactly two feature cards
    expect(find.text('Live Object Detector'), findsOneWidget);
    expect(find.text('AI Image Analyzer'), findsOneWidget);
    expect(find.text('Settings & Preferences'), findsNothing);

    // 3. Verify Click to start prompt on both cards
    expect(find.text('Click to start'), findsNWidgets(2));

    // 4. Verify simple, jargon-free descriptions (No TFLite)
    expect(find.text('Point your camera to detect and hear objects around you in real time'), findsOneWidget);
    expect(find.text('Take or choose a photo to hear a detailed description of the scene'), findsOneWidget);

    // 5. Verify profile avatar has correct semantic label
    final profileSemanticFinder = find.bySemanticsLabel('Profile: alex, tap to open menu');
    expect(profileSemanticFinder, findsOneWidget);
  });

  testWidgets('Tapping profile avatar opens bottom sheet with profile info & sign-out',
      (WidgetTester tester) async {
    await authCubit.signInWithEmail('alex@example.com', 'password');

    await tester.pumpWidget(buildTestWidget(cubit: authCubit));
    await tester.pumpAndSettle();

    // Tap profile avatar
    final avatarButton = find.bySemanticsLabel('Profile: alex, tap to open menu');
    await tester.tap(avatarButton);
    await tester.pumpAndSettle();

    // Verify Bottom Sheet content
    expect(find.text('Account Profile'), findsOneWidget);
    expect(find.text('alex'), findsOneWidget);
    expect(find.text('alex@example.com'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);

    // Tap Sign Out
    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();

    // Verify signOut was triggered
    expect(fakeRepo.signedOutCalled, isTrue);
  });

  testWidgets('Profile bottom sheet close button is accessible and dismisses sheet when tapped',
      (WidgetTester tester) async {
    await authCubit.signInWithEmail('alex@example.com', 'password');

    await tester.pumpWidget(buildTestWidget(cubit: authCubit));
    await tester.pumpAndSettle();

    // Tap profile avatar to open bottom sheet
    final avatarButton = find.bySemanticsLabel('Profile: alex, tap to open menu');
    await tester.tap(avatarButton);
    await tester.pumpAndSettle();

    // Verify Close button exists with 'Close' semantics label and button: true
    final closeButtonFinder = find.byWidgetPredicate((w) =>
        w is Semantics &&
        w.properties.button == true &&
        w.properties.label == 'Close');
    expect(closeButtonFinder, findsOneWidget);

    // Verify close button size meets minimum touch target (>= 48x48)
    final closeButtonSize = tester.getSize(closeButtonFinder);
    expect(closeButtonSize.height, greaterThanOrEqualTo(48.0));
    expect(closeButtonSize.width, greaterThanOrEqualTo(48.0));

    // Tap Close button
    await tester.tap(closeButtonFinder);
    await tester.pumpAndSettle();

    // Verify bottom sheet is dismissed
    expect(find.text('Account Profile'), findsNothing);
  });

  testWidgets('Feature cards and buttons have minimum 48x48 tap targets',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget(cubit: authCubit));
    await tester.pumpAndSettle();

    // Find Live Object Detector card tap target
    final detectorCard = tester.getRect(find.widgetWithText(InkWell, 'Live Object Detector'));
    expect(detectorCard.height, greaterThanOrEqualTo(48.0));
    expect(detectorCard.width, greaterThanOrEqualTo(48.0));

    // Find AI Image Analyzer card tap target
    final analyzerCard = tester.getRect(find.widgetWithText(InkWell, 'AI Image Analyzer'));
    expect(analyzerCard.height, greaterThanOrEqualTo(48.0));
    expect(analyzerCard.width, greaterThanOrEqualTo(48.0));
  });
}
