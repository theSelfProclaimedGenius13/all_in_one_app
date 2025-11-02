import 'package:equatable/equatable.dart';
import '../domain/user_entity.dart';

abstract class Auth_State extends Equatable {
  const Auth_State();

  @override
  // 4. ADD PROPS GETTER
  List<Object?> get props => [];
}

class AuthInitial extends Auth_State {
  // 5. ADD CONST
  const AuthInitial();
}

class AuthLoading extends Auth_State {
  // 6. ADD CONST
  const AuthLoading();
}

class AuthUnauthenticated extends Auth_State {
  // 7. ADD CONST
  const AuthUnauthenticated();
}

class AuthAuthenticated extends Auth_State {
  final UserEntity user;

  // 8. ADD CONST
  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthError extends Auth_State {
  final String error;

  // 9. ADD CONST
  const AuthError(this.error);

  @override
  List<Object?> get props => [error];
}
