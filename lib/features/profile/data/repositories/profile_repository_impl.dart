import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:all_in_one_app/features/profile/domain/profile.dart';
import 'package:all_in_one_app/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient _client = Supabase.instance.client;
  final String _tableName = 'profiles';

  // Helper to get the current user ID
  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<Profile> getProfile() async {
    try {
      final data = await _client
          .from(_tableName)
          .select()
          .eq('id', _userId)
          .maybeSingle();

      if (data != null) {
        return Profile.fromMap(data);
      } else {
        final newProfile = {'id': _userId, 'username': 'new_user'};

        final insertedData = await _client
            .from(_tableName)
            .insert(newProfile)
            .select()
            .single();

        return Profile.fromMap(insertedData);
      }
    } catch (e) {
      throw Exception('Error fetching/creating profile: $e');
    }
  }

  @override
  Future<void> updateUserEmail(String newEmail) async {
    try {
      // IMPORTANT: match the OAuth redirect you configured in AuthApi.signInWithProvider
      const String redirectUrl = 'allinoneapp://auth';

      await _client.auth.updateUser(
        UserAttributes(email: newEmail),
        emailRedirectTo: redirectUrl,
      );
    } catch (e) {
      throw Exception('Error updating email: $e');
    }
  }

  @override
  Future<void> updateProfile(Profile profile) async {
    try {
      final profileMap = profile.toMap()..remove('id');

      await _client.from(_tableName).update(profileMap).eq('id', _userId);
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }
}
