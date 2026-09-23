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
    return BlocProvider<AuthCubit>.value(
      value: cubit,
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

    // 3. Verify Start buttons on both cards
    expect(find.text('Start'), findsNWidgets(2));

    // 4. Verify profile avatar has correct semantic label
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

  testWidgets('Feature cards and buttons have minimum 48x48 tap targets',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget(cubit: authCubit));
    await tester.pumpAndSettle();

    // Find Start buttons
    final startButtons = tester.widgetList<ElevatedButton>(find.byType(ElevatedButton));
    for (final button in startButtons) {
      final minSize = button.style?.minimumSize?.resolve({});
      if (minSize != null) {
        expect(minSize.height, greaterThanOrEqualTo(48.0));
      }
    }
  });
}
