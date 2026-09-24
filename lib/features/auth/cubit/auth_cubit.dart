import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vision_companion/core/services/analytics_service.dart';
import 'package:vision_companion/core/services/crashlytics_service.dart';
import 'package:vision_companion/features/auth/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final CrashlyticsService? crashlyticsService;
  final AnalyticsService? analyticsService;
  StreamSubscription<User?>? _authSubscription;

  AuthCubit({
    required AuthRepository authRepository,
    this.crashlyticsService,
    this.analyticsService,
  })  : _authRepository = authRepository,
        super(
          authRepository.currentUser != null
              ? Authenticated.fromFirebaseUser(authRepository.currentUser!)
              : const Unauthenticated(),
        ) {
    if (authRepository.currentUser != null) {
      _syncUser(authRepository.currentUser);
    }
    _initAuthListener();
  }

  void _syncUser(User? user) {
    if (user != null) {
      crashlyticsService?.setUserId(user.uid);
      analyticsService?.setUserId(user.uid);
    } else {
      crashlyticsService?.setUserId('');
      analyticsService?.setUserId(null);
    }
  }

  void _initAuthListener() {
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      _syncUser(user);
      if (user != null) {
        emit(Authenticated.fromFirebaseUser(user));
      } else {
        emit(const Unauthenticated());
      }
    });
  }

  Future<void> signInWithEmail(String email, String password) async {
    emit(const Loading());
    try {
      final credential = await _authRepository.signInWithEmail(email, password);
      final user = credential?.user;
      if (user != null) {
        emit(Authenticated.fromFirebaseUser(user));
      }
    } on AuthFailure catch (failure) {
      emit(AuthError(failure));
    } catch (e) {
      emit(AuthError(AuthFailure.generic(e.toString())));
    }
  }

  Future<void> signUpWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async {
    emit(const Loading());
    try {
      final credential = await _authRepository.signUpWithEmail(
        email,
        password,
        displayName: displayName,
      );
      final user = credential?.user;
      if (user != null) {
        emit(Authenticated.fromFirebaseUser(user));
      }
    } on AuthFailure catch (failure) {
      emit(AuthError(failure));
    } catch (e) {
      emit(AuthError(AuthFailure.generic(e.toString())));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(const Loading());
    try {
      final credential = await _authRepository.signInWithGoogle();
      final user = credential?.user;
      if (user != null) {
        emit(Authenticated.fromFirebaseUser(user));
      }
    } on AuthFailure catch (failure) {
      emit(AuthError(failure));
    } catch (e) {
      emit(AuthError(AuthFailure.generic(e.toString())));
    }
  }

  Future<void> signOut() async {
    emit(const Loading());
    try {
      await _authRepository.signOut();
      emit(const Unauthenticated());
    } on AuthFailure catch (failure) {
      emit(AuthError(failure));
    } catch (e) {
      emit(AuthError(AuthFailure.generic(e.toString())));
    }
  }

  @override
  void emit(AuthState state) {
    if (isClosed) return;
    super.emit(state);
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}
