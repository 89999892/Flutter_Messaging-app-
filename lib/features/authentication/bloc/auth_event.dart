import 'package:equatable/equatable.dart';
import '../../../common/models/user_model.dart';

/// Base class for all authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event when user requests login
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Event when user requests registration
class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

/// Event when user requests logout
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Event when user requests password reset
class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Event when auth state changes (from Firebase)
class AuthStateChanged extends AuthEvent {
  final UserModel? user;

  const AuthStateChanged(this.user);

  @override
  List<Object?> get props => [user];
}
