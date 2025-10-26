import '../domain/user_entity.dart';
import 'auth_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final AuthApi api;

  AuthRepository(this.api);

  Future<UserEntity?> loginWithEmail(String email, String password) async {
    final response = await api.signInWithEmail(email, password);
    final user = response.user;
    if (user == null) return null;
    return UserEntity(
      id: user.id,
      email: user.email ?? "",
      phone: user.phone,
      name: user.userMetadata?["name"],
      username: user.userMetadata?["username"],
      avatarUrl: user.userMetadata?["avatar_url"],
      dateOfBirth: null,
      country: user.userMetadata?["country"],
      linkedProviders: [], // add logic as needed
    );
  }

  Future<void> loginWithProvider(OAuthProvider provider) async {
    await api.signInWithProvider(provider);
  }

  Future<dynamic> signUpWithEmail(String email, String password) {
    return api.signUpWithEmail(email, password);
  }

  Future<void> logout() => api.signOut();
}
