import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vision_companion/features/auth/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authSubscription;

  AuthCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(
          authRepository.currentUser != null
              ? Authenticated.fromFirebaseUser(authRepository.currentUser!)
              : const Unauthenticated(),
        ) {
    _initAuthListener();
  }

  void _initAuthListener() {
    _authSubscription = _authRepository.authStateChanges.listen((user) {
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
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}
