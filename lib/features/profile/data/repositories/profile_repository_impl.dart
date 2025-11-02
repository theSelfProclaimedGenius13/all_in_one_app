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
      // 1. Try to get the profile using .maybeSingle()
      //    .maybeSingle() safely returns 'null' if it finds 0 rows.
      final data = await _client
          .from(_tableName)
          .select()
          .eq('id', _userId)
          .maybeSingle();

      // 2. Check if a profile was found
      if (data != null) {
        // Profile exists, return it.
        return Profile.fromMap(data);
      } else {
        // --- 3. Profile does NOT exist, so we create one ---
        // We create a new, empty profile map to insert
        final newProfile = {
          'id': _userId,
          'username': 'new_user', // You can set any default you want
          // full_name, avatar_url, etc., will be null
        };

        // Insert the new row and return it
        final insertedData = await _client
            .from(_tableName)
            .insert(newProfile)
            .select()
            .single(); // Use .single() here, we know it exists

        return Profile.fromMap(insertedData);
      }
    } catch (e) {
      throw Exception('Error fetching/creating profile: $e');
    }
  }

  @override
  Future<void> updateUserEmail(String newEmail) async {
    try {
      // This is the built-in Supabase function
      // It will automatically send a verification link to the *new* email.
      // The email won't actually change until the user clicks that link.
      const String redirectUrl = 'allinoneapp://login';

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
      // Convert the Profile object to a Map, but remove the 'id'
      // as we don't want to (and can't) update the primary key.
      final profileMap = profile.toMap()..remove('id');

      await _client
          .from(_tableName)
          .update(profileMap)
          .eq('id', _userId); // Only update the row matching the user's ID
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }
}
