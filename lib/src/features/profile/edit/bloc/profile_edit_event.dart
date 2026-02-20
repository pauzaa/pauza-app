part of 'profile_edit_bloc.dart';

sealed class ProfileEditEvent extends Equatable {
  const ProfileEditEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class ProfileEditStarted extends ProfileEditEvent {
  const ProfileEditStarted();
}

final class ProfileEditSaveRequested extends ProfileEditEvent {
  const ProfileEditSaveRequested({
    required this.name,
    required this.username,
    required this.profilePictureUrl,
    required this.profilePictureBytes,
  });

  final String name;
  final String username;
  final String? profilePictureUrl;
  final Uint8List? profilePictureBytes;

  @override
  List<Object?> get props => <Object?>[
    name,
    username,
    profilePictureUrl,
    profilePictureBytes,
  ];
}
