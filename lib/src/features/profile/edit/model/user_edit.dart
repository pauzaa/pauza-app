import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';

@immutable
class ProfileEditDTO {
  const ProfileEditDTO({
    required this.name,
    required this.username,
    this.profilePictureUrl,
    this.profilePictureBytes,
  });

  const ProfileEditDTO.initial()
    : this(
        name: '',
        username: '',
        profilePictureUrl: null,
        profilePictureBytes: null,
      );

  factory ProfileEditDTO.fromUserDto(UserDto user) => ProfileEditDTO(
    name: user.name,
    username: user.username,
    profilePictureUrl: user.profilePicture,
  );

  final String name;
  final String username;
  final String? profilePictureUrl;
  final Uint8List? profilePictureBytes;

  dynamic get effectifeProfilePicture =>
      profilePictureBytes ?? profilePictureUrl;

  ProfileEditDTO copyWith({
    String? name,
    String? username,
    String? profilePictureUrl,
    Uint8List? profilePictureBytes,
  }) => ProfileEditDTO(
    name: name ?? this.name,
    username: username ?? this.username,
    profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    profilePictureBytes: profilePictureBytes ?? this.profilePictureBytes,
  );

  @override
  String toString() {
    return 'ProfileEditDTO(name: $name, username: $username, profilePictureUrl: $profilePictureUrl, profilePictureBytes: $profilePictureBytes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is ProfileEditDTO &&
        other.name == name &&
        other.username == username &&
        other.profilePictureUrl == profilePictureUrl &&
        other.profilePictureBytes == profilePictureBytes;
  }

  @override
  int get hashCode =>
      Object.hash(name, username, profilePictureUrl, profilePictureBytes);
}
