import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthEvent extends Equatable {
  // 2. ADD CONST CONSTRUCTOR
  const AuthEvent();

  @override
  // 3. ADD PROPS
  List<Object?> get props => [];
}

// This event is added by the BLoC itself
class AuthStateChanged extends AuthEvent {
  final AuthState data;

  const AuthStateChanged(this.data);

  @override
  List<Object?> get props => [data];
}

// This event is fired from the UI
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

// This event is fired from the UI
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

// This event is fired from the signup screen
class SignupRequested extends AuthEvent {
  final String email, password;

  const SignupRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SocialLoginRequested extends AuthEvent {
  final OAuthProvider provider;

  const SocialLoginRequested(this.provider); // e.g. 'google', 'facebook'
  @override
  List<Object?> get props => [provider];
}
