import 'package:flutter/foundation.dart';

@immutable
final class UserDto {
  const UserDto({
    required this.profilePicture,
    required this.username,
    required this.name,
  });

  final String profilePicture;
  final String username;
  final String name;

  @override
  String toString() {
    return 'UserDto('
        'profilePicture: $profilePicture, '
        'username: $username, '
        'name: $name'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is UserDto &&
        other.profilePicture == profilePicture &&
        other.username == username &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(profilePicture, username, name);
}
