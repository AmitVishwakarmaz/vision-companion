import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vision_companion/l10n/app_localizations.dart';

enum AuthFailureType {
  userNotFound,
  wrongPassword,
  invalidEmail,
  userDisabled,
  tooManyRequests,
  networkFailed,
  googleCancelled,
  generic,
}

class AuthFailure implements Exception {
  final AuthFailureType type;
  final String? customMessage;

  const AuthFailure(this.type, {this.customMessage});

  factory AuthFailure.fromFirebaseException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthFailure(AuthFailureType.userNotFound);
      case 'wrong-password':
      case 'invalid-credential':
        return const AuthFailure(AuthFailureType.wrongPassword);
      case 'invalid-email':
        return const AuthFailure(AuthFailureType.invalidEmail);
      case 'user-disabled':
        return const AuthFailure(AuthFailureType.userDisabled);
      case 'too-many-requests':
        return const AuthFailure(AuthFailureType.tooManyRequests);
      case 'network-request-failed':
        return const AuthFailure(AuthFailureType.networkFailed);
      default:
        return AuthFailure(AuthFailureType.generic, customMessage: e.message);
    }
  }

  factory AuthFailure.googleCancelled() {
    return const AuthFailure(AuthFailureType.googleCancelled);
  }

  factory AuthFailure.generic([String? message]) {
    return AuthFailure(AuthFailureType.generic, customMessage: message);
  }

  String toLocalizedMessage(AppLocalizations l10n) {
    switch (type) {
      case AuthFailureType.userNotFound:
        return l10n.authErrorUserNotFound;
      case AuthFailureType.wrongPassword:
        return l10n.authErrorWrongPassword;
      case AuthFailureType.invalidEmail:
        return l10n.authErrorInvalidEmail;
      case AuthFailureType.userDisabled:
        return l10n.authErrorUserDisabled;
      case AuthFailureType.tooManyRequests:
        return l10n.authErrorTooManyRequests;
      case AuthFailureType.networkFailed:
        return l10n.authErrorNetworkFailed;
      case AuthFailureType.googleCancelled:
        return l10n.authErrorGoogleCancelled;
      case AuthFailureType.generic:
        return customMessage ?? l10n.authErrorGeneric;
    }
  }

  @override
  String toString() => 'AuthFailure(type: $type, message: $customMessage)';
}

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  Future<UserCredential?> signInWithEmail(String email, String password);
  Future<UserCredential?> signInWithGoogle();
  Future<void> signOut();
}

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth? firebaseAuth;
  final GoogleSignIn? googleSignIn;

  FirebaseAuthRepository({
    this.firebaseAuth,
    this.googleSignIn,
  });

  @override
  Stream<User?> get authStateChanges {
    final auth = firebaseAuth;
    if (auth != null) {
      return auth.authStateChanges();
    }
    return const Stream.empty();
  }

  @override
  User? get currentUser => firebaseAuth?.currentUser;

  @override
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    final auth = firebaseAuth;
    if (auth == null) {
      throw AuthFailure.generic('Authentication service unavailable.');
    }

    try {
      return await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromFirebaseException(e);
    } catch (e) {
      throw AuthFailure.generic(e.toString());
    }
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    final auth = firebaseAuth;
    final google = googleSignIn ?? GoogleSignIn.instance;

    if (auth == null) {
      throw AuthFailure.generic('Authentication service unavailable.');
    }

    try {
      final GoogleSignInAccount account = await google.authenticate();
      final String? idToken = account.authentication.idToken;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      return await auth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw AuthFailure.googleCancelled();
      }
      throw AuthFailure.generic(e.description ?? 'Google sign-in failed');
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromFirebaseException(e);
    } on AuthFailure {
      rethrow;
    } catch (e) {
      throw AuthFailure.generic(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      final google = googleSignIn ?? GoogleSignIn.instance;
      await google.signOut();
    } catch (_) {}

    try {
      await firebaseAuth?.signOut();
    } catch (e) {
      throw AuthFailure.generic(e.toString());
    }
  }
}
