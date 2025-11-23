import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Authentication BLoC
/// Manages authentication state and business logic
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription? _authStateSubscription;

  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    // Listen to auth state changes and add internal event
    _authStateSubscription = _authRepository.authStateChanges.listen((user) {
      add(AuthStateChanged(user));
    });

    // Register event handlers
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthStateChanged>(_onAuthStateChanged);
  }

  /// Handle auth state changes from Firebase
  void _onAuthStateChanged(
    AuthStateChanged event,
    Emitter<AuthState> emit,
  ) {
    if (event.user != null) {
      emit(AuthAuthenticated(user: event.user!));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  /// Handle login request
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await _authRepository.signInWithEmail(
        event.email,
        event.password,
      );

      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
      emit(const AuthUnauthenticated());
    }
  }

  /// Handle registration request
  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await _authRepository.signUpWithEmail(
        event.email,
        event.password,
        event.displayName,
      );

      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
      emit(const AuthUnauthenticated());
    }
  }

  /// Handle logout request
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _authRepository.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handle password reset request
  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await _authRepository.resetPassword(event.email);
      emit(const AuthPasswordResetSent());
    } catch (e) {
      emit(AuthError(message: e.toString()));
      emit(const AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
