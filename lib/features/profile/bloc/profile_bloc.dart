import 'package:all_in_one_app/features/profile/bloc/profile_event.dart';
import 'package:all_in_one_app/features/profile/bloc/profile_state.dart';
import 'package:all_in_one_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileBloc({required ProfileRepository profileRepository})
    : _profileRepository = profileRepository,
      super(const ProfileState()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<ChangeEmailRequested>(_onChangeEmailRequested);
  }

  /// Handle loading the profile
  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final profile = await _profileRepository.getProfile();
      emit(state.copyWith(status: ProfileStatus.success, profile: profile));
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Handle updating the profile
  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    // --- 1. FIX: EMIT 'LOADING' STATE FIRST ---
    // This ensures our listener will always see a state change
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      await _profileRepository.updateProfile(event.profile);
      // Emit the new profile data to update the UI
      // --- 2. NOW EMIT 'SUCCESS' ---
      // This is now different from the 'loading' state,
      // so the listener in the UI *will* fire.
      emit(
        state.copyWith(status: ProfileStatus.success, profile: event.profile),
      );
    } catch (e) {
      // If saving fails, emit an error but keep the (unsaved) profile
      // data so the user doesn't lose their changes.
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onChangeEmailRequested(
    ChangeEmailRequested event,
    Emitter<ProfileState> emit,
  ) async {
    // We don't need a loading state, this should be fast
    try {
      await _profileRepository.updateUserEmail(event.newEmail);
      // We don't change the state here, but we could
      // emit a "success" message for a SnackBar.
      // For now, we'll let the UI show the SnackBar.
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
