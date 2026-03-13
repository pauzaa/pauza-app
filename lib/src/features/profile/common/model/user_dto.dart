import 'package:flutter/foundation.dart';

@immutable
final class UserDto {
  const UserDto({
    required this.profilePicture,
    required this.username,
    required this.name,
    this.id = '',
    this.email = '',
  });

  factory UserDto.fromJson(Map<String, Object?> json) => UserDto(
    id: json['id'] as String? ?? '',
    email: json['email'] as String? ?? '',
    profilePicture: json['profile_picture_url'] as String? ?? json['profilePicture'] as String?,
    username: json['username'] as String? ?? '',
    name: json['name'] as String? ?? '',
  );

  final String id;
  final String email;
  final String? profilePicture;
  final String username;
  final String name;

  @override
  String toString() {
    return 'UserDto('
        'id: $id, '
        'email: $email, '
        'profilePicture: $profilePicture, '
        'username: $username, '
        'name: $name'
        ')';
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'email': email,
    'profilePicture': profilePicture,
    'username': username,
    'name': name,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is UserDto &&
        other.id == id &&
        other.email == email &&
        other.profilePicture == profilePicture &&
        other.username == username &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, email, profilePicture, username, name);
}
