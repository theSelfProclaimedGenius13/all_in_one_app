import 'package:supabase_flutter/supabase_flutter.dart';

class AuthApi {
  final SupabaseClient client = Supabase.instance.client;

  // Email/password
  Future<AuthResponse> signUpWithEmail(String email, String password) {
    return client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signInWithEmail(String email, String password) {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  // Social login - pass provider as string: 'google', 'facebook', etc.
  Future<void> signInWithProvider(OAuthProvider provider) async {
    await client.auth.signInWithOAuth(
      provider,
      redirectTo: 'allinoneapp://auth',
    );
  }

  Future<void> signOut() => client.auth.signOut();
}
