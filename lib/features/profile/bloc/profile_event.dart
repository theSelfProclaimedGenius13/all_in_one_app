import 'package:equatable/equatable.dart';

import '../domain/profile.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load the user's profile from the repository
class LoadProfile extends ProfileEvent {}

/// Event to update the user's profile
class UpdateProfile extends ProfileEvent {
  final Profile profile;

  const UpdateProfile(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ChangeEmailRequested extends ProfileEvent {
  final String newEmail;

  const ChangeEmailRequested(this.newEmail);

  @override
  List<Object?> get props => [newEmail];
}
