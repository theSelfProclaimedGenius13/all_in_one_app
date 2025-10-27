import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/user_entity.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../data/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthBloc extends Bloc<AuthEvent, Auth_State> {
  final AuthRepository repository;

  // --- ADD THIS VARIABLE ---
  StreamSubscription<AuthState>? _authStreamSubscription;

  AuthBloc(this.repository) : super(AuthInitial()) {
    // --- ADD THIS LISTENER IN THE CONSTRUCTOR ---
    _authStreamSubscription = Supabase.instance.client.auth.onAuthStateChange
        .listen((data) {
          // Add our internal event whenever Supabase's auth state changes
          add(AuthStateChanged(data));
        });
    // --- END OF NEW CODE ---

    // --- ADD THIS HANDLER ---
    on<AuthStateChanged>((event, emit) {
      final user = event.data.session?.user; // Get the Supabase user

      if (user != null) {
        // User is logged in! Map them to your app's UserEntity.
        // This is the same mapping logic from your repository.
        final userEntity = UserEntity(
          id: user.id,
          email: user.email ?? "",
          phone: user.phone,
          name: user.userMetadata?['name'],
          username: user.userMetadata?['username'],
          avatarUrl: user.userMetadata?['avatar_url'],
          dateOfBirth: null,
          // You'd need to parse this if it exists
          country: user.userMetadata?['country'],
          linkedProviders: [], // You'd need logic for this
        );
        emit(AuthAuthenticated(userEntity));
      } else {
        // User is null, they are logged out.
        emit(AuthInitial());
      }
    });
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await repository.loginWithEmail(
          event.email,
          event.password,
        );
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthError('Login failed'));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<SignupRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await repository.signUpWithEmail(event.email, event.password);
        emit(AuthInitial());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<SocialLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await repository.loginWithProvider(event.provider);
        emit(AuthInitial());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) async {
      await repository.logout();
      emit(AuthInitial());
    });
  }

  @override
  Future<void> close() {
    _authStreamSubscription?.cancel();
    return super.close();
  }
}
