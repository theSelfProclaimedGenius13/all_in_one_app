import '../domain/user_entity.dart';

abstract class Auth_State {}

class AuthInitial extends Auth_State {}

class AuthLoading extends Auth_State {}

class AuthAuthenticated extends Auth_State {
  final UserEntity user;

  AuthAuthenticated(this.user);
}

class AuthError extends Auth_State {
  final String error;

  AuthError(this.error);
}
