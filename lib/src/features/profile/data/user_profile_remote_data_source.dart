import 'dart:typed_data';

import 'package:pauza/src/features/profile/common/model/user_dto.dart';
import 'package:pauza/src/features/profile/common/model/user_profile_failure.dart';

abstract interface class UserProfileRemoteDataSource {
  Future<UserDto> fetchMe();

  Future<UserDto> updateMe({
    required String name,
    required String username,
    String? profilePictureUrl,
    Uint8List? profilePictureBytes,
  });

  Future<bool> isUsernameAvailable({required String username});

  Future<String> uploadProfilePhoto({required String localFilePath});
}

final class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  const UserProfileRemoteDataSourceImpl();

  @override
  Future<UserDto> fetchMe() async {
    return const UserDto(
      profilePicture:
          'https://media.istockphoto.com/id/500593190/photo/composition-finger-frame-mans-hands-capture-the-sunset.jpg?s=612x612&w=0&k=20&c=S7cuvvC_hlu39Fj5jon6__3DD0j265aAsqvYX4C0lEM=',
      username: 'john',
      name: 'John',
    );
  }

  @override
  Future<UserDto> updateMe({
    required String name,
    required String username,
    String? profilePictureUrl,
    Uint8List? profilePictureBytes,
  }) async {
    final normalizedUsername = _normalizeUsername(username);
    final normalizedName = name.trim();
    if (normalizedUsername.isEmpty || normalizedName.isEmpty) {
      throw const UserProfileValidationError();
    }

    final available = await isUsernameAvailable(username: normalizedUsername);
    if (!available) {
      throw const UserProfileUsernameTakenError();
    }

    final resolvedProfilePicture = profilePictureBytes == null ? profilePictureUrl : 'memory://profile';
    final user = UserDto(
      profilePicture: resolvedProfilePicture ?? '',
      username: normalizedUsername,
      name: normalizedName,
    );
    return user;
  }

  @override
  Future<bool> isUsernameAvailable({required String username}) async {
    final normalizedUsername = _normalizeUsername(username);
    if (normalizedUsername.isEmpty) {
      throw const UserProfileValidationError();
    }

    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (username == 'alreadytaken') {
      return false;
    }
    return true;
  }

  @override
  Future<String> uploadProfilePhoto({required String localFilePath}) async {
    if (localFilePath.trim().isEmpty) {
      throw const UserProfileValidationError();
    }

    final photoUrl = 'https://example.com/avatar/john-$localFilePath';
    return photoUrl;
  }

  String _normalizeUsername(String username) {
    final trimmed = username.trim();
    if (trimmed.startsWith('@')) {
      return trimmed.substring(1).toLowerCase();
    }
    return trimmed.toLowerCase();
  }
}
