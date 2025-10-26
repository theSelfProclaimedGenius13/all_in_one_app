import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../data/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, Auth_State> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(AuthInitial()) {
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
}
