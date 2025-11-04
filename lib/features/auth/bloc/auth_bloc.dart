import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:all_in_one_app/features/auth/bloc/auth_state.dart';
import 'package:all_in_one_app/features/auth/bloc/auth_event.dart';
import 'package:all_in_one_app/features/auth/data/auth_repository.dart';
import 'package:all_in_one_app/features/auth/domain/user_entity.dart';

class AuthBloc extends Bloc<AuthEvent, Auth_State> {
  final AuthRepository authRepository;
  StreamSubscription<AuthState>? _authStateSubscription;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<SignupRequested>(_onSignupRequested);
    on<SocialLoginRequested>(_onSocialLoginRequested);
    on<AuthStateChanged>(_onAuthStateChanged);

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

  // Robust: use currentUser when present, and don't drop to unauth during email verify flow
  void _onAuthStateChanged(AuthStateChanged event, Emitter<Auth_State> emit) {
    final auth = Supabase.instance.client.auth;
    final session = event.data.session;
    final supaUser = auth.currentUser ?? session?.user;

    if (supaUser != null) {
      final userEntity = UserEntity(
        id: supaUser.id,
        email: supaUser.email ?? '',
        phone: supaUser.phone ?? '',
        name: supaUser.userMetadata?['name'],
        username: supaUser.userMetadata?['username'],
        avatarUrl: supaUser.userMetadata?['avatar_url'],
        dateOfBirth: supaUser.userMetadata?['dateOfBirth'],
        country: supaUser.userMetadata?['country'],
        linkedProviders: const [],
      );
      emit(AuthAuthenticated(userEntity));
      return;
    }

    // Truly signed out
    emit(const AuthUnauthenticated());
  }
}
