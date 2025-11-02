import 'package:all_in_one_app/features/profile/domain/profile.dart';

abstract class ProfileRepository {
  // Fetches the profile for the currently logged-in user
  Future<Profile> getProfile();

  // Updates the profile for the currently logged-in user
  Future<void> updateProfile(Profile profile);

  // Updates the user's secure email (requires verification)
  Future<void> updateUserEmail(String newEmail);
}
