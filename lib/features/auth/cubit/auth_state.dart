import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vision_companion/features/auth/repositories/auth_repository.dart';
import 'package:vision_companion/l10n/app_localizations.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class Loading extends AuthState {
  const Loading();
}

typedef AuthLoading = Loading;

class Authenticated extends AuthState {
  final User? user;
  final String userId;
  final String? email;
  final String? displayName;

  const Authenticated({
    this.user,
    required this.userId,
    this.email,
    this.displayName,
  });

  factory Authenticated.fromFirebaseUser(User user) {
    return Authenticated(
      user: user,
      userId: user.uid,
      email: user.email,
      displayName: user.displayName,
    );
  }

  @override
  List<Object?> get props => [userId, email, displayName];
}

class AuthError extends AuthState {
  final AuthFailure failure;

  const AuthError(this.failure);

  String getLocalizedMessage(AppLocalizations l10n) => failure.toLocalizedMessage(l10n);

  @override
  List<Object?> get props => [failure];
}

typedef Error = AuthError;
