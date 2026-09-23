import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth? firebaseAuth;

  AuthCubit({this.firebaseAuth})
      : super(const AuthInitial()) {
    checkAuthStatus();
  }

  void checkAuthStatus() {
    try {
      final user = firebaseAuth?.currentUser;
      if (user != null) {
        emit(Authenticated(
          userId: user.uid,
          email: user.email,
          displayName: user.displayName,
        ));
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(const Unauthenticated());
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    emit(const AuthLoading());
    try {
      final auth = firebaseAuth;
      if (auth != null) {
        final credential = await auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );
        final user = credential.user;
        if (user != null) {
          emit(Authenticated(
            userId: user.uid,
            email: user.email,
            displayName: user.displayName,
          ));
          return;
        }
      }
      // Demo/Fallback authentication for testing or offline environment
      emit(Authenticated(
        userId: 'demo-user-123',
        email: email.trim(),
        displayName: email.split('@').first,
      ));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Authentication failed'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());
    try {
      // In initial project skeleton, emit demo user or handle provider
      emit(const Authenticated(
        userId: 'google-user-id',
        email: 'user@example.com',
        displayName: 'Vision User',
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(const AuthLoading());
    try {
      await firebaseAuth?.signOut();
      emit(const Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
