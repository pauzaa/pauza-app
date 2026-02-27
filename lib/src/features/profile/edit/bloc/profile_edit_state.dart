part of 'profile_edit_bloc.dart';

sealed class ProfileEditState {
  const ProfileEditState();

  ProfileEditState loading() => const ProfileEditLoading();
  ProfileEditState ready(UserDto user) => ProfileEditReady(user: user);
  ProfileEditState saving() => const ProfileEditSaving();
  ProfileEditState success() => const ProfileEditSuccess();
  ProfileEditState failure(Object error) => ProfileEditFailure(error: error);

  bool get isReady => this is ProfileEditReady;
  bool get isSaving => this is ProfileEditSaving;
  bool get isSuccess => this is ProfileEditSuccess;
}

class ProfileEditInitial extends ProfileEditState {
  const ProfileEditInitial();
}

class ProfileEditLoading extends ProfileEditState {
  const ProfileEditLoading();
}

class ProfileEditReady extends ProfileEditState {
  const ProfileEditReady({required this.user});

  final UserDto user;
}

class ProfileEditSaving extends ProfileEditState {
  const ProfileEditSaving();
}

class ProfileEditSuccess extends ProfileEditState {
  const ProfileEditSuccess();
}

class ProfileEditFailure extends ProfileEditState {
  const ProfileEditFailure({required this.error});

  final Object error;
}
