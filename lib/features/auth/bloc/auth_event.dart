import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email, password;

  LoginRequested(this.email, this.password);
}

class SignupRequested extends AuthEvent {
  final String email, password;

  SignupRequested(this.email, this.password);
}

class SocialLoginRequested extends AuthEvent {
  final OAuthProvider provider;

  SocialLoginRequested(this.provider); // e.g. 'google', 'facebook'
}

class LogoutRequested extends AuthEvent {}
