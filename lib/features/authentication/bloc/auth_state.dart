import 'package:equatable/equatable.dart';
import '../../../common/models/user_model.dart';

/// Base class for all authentication states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state (during authentication operations)
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated state (user is logged in)
class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated state (user is logged out)
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Error state
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Password reset email sent
class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent();
}
