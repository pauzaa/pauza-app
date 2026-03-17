import 'package:flutter/foundation.dart';

@immutable
final class BasicUserDto {
  const BasicUserDto({
    required this.id,
    required this.name,
    required this.username,
    this.profilePictureUrl,
  });

  factory BasicUserDto.fromJson(Map<String, Object?> json) => BasicUserDto(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    username: json['username'] as String? ?? '',
    profilePictureUrl: json['profile_picture_url'] as String?,
  );

  final String id;
  final String name;
  final String username;
  final String? profilePictureUrl;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'name': name,
    'username': username,
    'profile_picture_url': profilePictureUrl,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BasicUserDto &&
          id == other.id &&
          name == other.name &&
          username == other.username &&
          profilePictureUrl == other.profilePictureUrl;

  @override
  int get hashCode => Object.hash(id, name, username, profilePictureUrl);

  @override
  String toString() =>
      'BasicUserDto(id: $id, name: $name, username: $username, '
      'profilePictureUrl: $profilePictureUrl)';
}
