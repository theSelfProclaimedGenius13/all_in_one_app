import 'package:equatable/equatable.dart';

import '../domain/profile.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final Profile? profile; // Nullable, as it might not be loaded yet
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    Profile? profile,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage, // Don't carry over old errors
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage];
}
