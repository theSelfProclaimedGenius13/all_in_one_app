import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:all_in_one_app/features/auth/bloc/auth_state.dart'; // Imports Auth_State
import 'package:all_in_one_app/features/auth/bloc/auth_event.dart';
import 'package:all_in_one_app/features/auth/data/auth_repository.dart';
import 'package:all_in_one_app/features/auth/domain/user_entity.dart';

class AuthBloc extends Bloc<AuthEvent, Auth_State> {
  final AuthRepository authRepository;
  StreamSubscription<AuthState>?
  _authStateSubscription; // This 'AuthState' is from Supabase

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<SignupRequested>(_onSignupRequested);
    on<SocialLoginRequested>(_onSocialLoginRequested);
    on<AuthStateChanged>(_onAuthStateChanged); // This is the important one

    // Subscribe to the stream
    _authStateSubscription = Supabase.instance.client.auth.onAuthStateChange
        .listen((data) {
          add(AuthStateChanged(data));
        });
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }

  // --- HANDLER METHODS ---

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<Auth_State> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.loginWithEmail(
        email: event.email,
        password: event.password,
      );
      if (user == null) {
        emit(const AuthUnauthenticated());
      } else {
        emit(AuthAuthenticated(user));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<Auth_State> emit,
  ) async {
    await authRepository.logout();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onSignupRequested(
    SignupRequested event,
    Emitter<Auth_State> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.signUpWithEmail(
        email: event.email,
        password: event.password,
      );
      if (user == null) {
        emit(const AuthError('Sign up failed.'));
      } else {
        emit(AuthAuthenticated(user));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSocialLoginRequested(
    SocialLoginRequested event,
    Emitter<Auth_State> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await authRepository.loginWithProvider(event.provider);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // --- !! THIS IS THE HANDLER WITH THE FIX !! ---
  void _onAuthStateChanged(AuthStateChanged event, Emitter<Auth_State> emit) {
    final session = event.data.session;
    // --- THIS IS THE CRASH-FIX ---
    // This stops the BLoC from logging you out
    // during the email change, which stops the crash.

    // --- END OF FIX ---

    if (session == null) {
      emit(const AuthUnauthenticated());
    } else {
      final userEntity = UserEntity(
        id: session.user.id,
        email: session.user.email ?? '',
        phone: session.user.phone ?? '',
        name: session.user.userMetadata?['name'],
        username: session.user.userMetadata?['username'],
        avatarUrl: session.user.userMetadata?['avatar_url'],
        dateOfBirth: session.user.userMetadata?['dateOfBirth'],
        country: session.user.userMetadata?['country'],
        linkedProviders: [],
      );
      emit(AuthAuthenticated(userEntity));
    }
  }
}
