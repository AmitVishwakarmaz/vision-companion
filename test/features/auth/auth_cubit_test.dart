import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vision_companion/features/auth/cubit/auth_cubit.dart';
import 'package:vision_companion/features/auth/cubit/auth_state.dart';
import 'package:vision_companion/features/auth/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  final StreamController<User?> _controller = StreamController<User?>.broadcast();
  User? _user;
  bool shouldThrow = false;
  AuthFailureType failureType = AuthFailureType.generic;

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  User? get currentUser => _user;

  void emitAuthState(User? user) {
    _user = user;
    _controller.add(user);
  }

  @override
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    if (shouldThrow) {
      throw AuthFailure(failureType);
    }
    return null;
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    if (shouldThrow) {
      throw AuthFailure(failureType);
    }
    return null;
  }

  @override
  Future<void> signOut() async {
    if (shouldThrow) {
      throw AuthFailure(failureType);
    }
    emitAuthState(null);
  }

  void dispose() {
    _controller.close();
  }
}

void main() {
  late FakeAuthRepository fakeRepo;
  late AuthCubit cubit;

  setUp(() {
    fakeRepo = FakeAuthRepository();
    cubit = AuthCubit(authRepository: fakeRepo);
  });

  tearDown(() async {
    await cubit.close();
    fakeRepo.dispose();
  });

  group('AuthCubit', () {
    test('initial state is Unauthenticated when no currentUser', () {
      expect(cubit.state, isA<Unauthenticated>());
    });

    test('emits Unauthenticated when authStateChanges emits null', () async {
      final states = <AuthState>[];
      final subscription = cubit.stream.listen(states.add);

      fakeRepo.emitAuthState(null);
      await pumpEventQueue();

      expect(states, contains(const Unauthenticated()));
      await subscription.cancel();
    });

    test('emits Loading then AuthError on signInWithEmail failure', () async {
      fakeRepo.shouldThrow = true;
      fakeRepo.failureType = AuthFailureType.wrongPassword;

      final states = <AuthState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.signInWithEmail('test@example.com', 'password123');
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], isA<Loading>());
      expect(states[1], isA<AuthError>());
      final error = states[1] as AuthError;
      expect(error.failure.type, equals(AuthFailureType.wrongPassword));

      await subscription.cancel();
    });

    test('emits Loading then AuthError on Google sign-in cancel', () async {
      fakeRepo.shouldThrow = true;
      fakeRepo.failureType = AuthFailureType.googleCancelled;

      final states = <AuthState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.signInWithGoogle();
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], isA<Loading>());
      expect(states[1], isA<AuthError>());
      final error = states[1] as AuthError;
      expect(error.failure.type, equals(AuthFailureType.googleCancelled));

      await subscription.cancel();
    });

    test('signOut emits Loading then Unauthenticated', () async {
      final states = <AuthState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.signOut();
      await pumpEventQueue();

      expect(states, contains(isA<Loading>()));
      expect(states, contains(isA<Unauthenticated>()));

      await subscription.cancel();
    });
  });

  group('AuthFailure mapping', () {
    test('maps Firebase exception codes accurately', () {
      final userNotFound = AuthFailure.fromFirebaseException(
        FirebaseAuthException(code: 'user-not-found'),
      );
      expect(userNotFound.type, equals(AuthFailureType.userNotFound));

      final wrongPassword = AuthFailure.fromFirebaseException(
        FirebaseAuthException(code: 'wrong-password'),
      );
      expect(wrongPassword.type, equals(AuthFailureType.wrongPassword));

      final invalidEmail = AuthFailure.fromFirebaseException(
        FirebaseAuthException(code: 'invalid-email'),
      );
      expect(invalidEmail.type, equals(AuthFailureType.invalidEmail));

      final tooMany = AuthFailure.fromFirebaseException(
        FirebaseAuthException(code: 'too-many-requests'),
      );
      expect(tooMany.type, equals(AuthFailureType.tooManyRequests));
    });
  });
}
