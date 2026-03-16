import 'package:flutter/foundation.dart';

@immutable
final class BasicUserDto {
  const BasicUserDto({
    required this.id,
    required this.name,
    required this.username,
    this.profilePictureUrl,
    this.leaderboardVisible = false,
  });

  factory BasicUserDto.fromJson(Map<String, Object?> json) => BasicUserDto(
    id: json['id'] as String? ?? json['ID'] as String? ?? '',
    name: json['name'] as String? ?? json['Name'] as String? ?? '',
    username: json['username'] as String? ?? json['Username'] as String? ?? '',
    profilePictureUrl: json['profile_picture_url'] as String? ?? json['ProfilePictureURL'] as String?,
    leaderboardVisible: json['leaderboard_visible'] as bool? ?? json['LeaderboardVisible'] as bool? ?? false,
  );

  final String id;
  final String name;
  final String username;
  final String? profilePictureUrl;
  final bool leaderboardVisible;

  Map<String, Object?> toJson() => <String, Object?>{
    'ID': id,
    'Name': name,
    'Username': username,
    'ProfilePictureURL': profilePictureUrl,
    'LeaderboardVisible': leaderboardVisible,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BasicUserDto &&
          id == other.id &&
          name == other.name &&
          username == other.username &&
          profilePictureUrl == other.profilePictureUrl &&
          leaderboardVisible == other.leaderboardVisible;

  @override
  int get hashCode => Object.hash(id, name, username, profilePictureUrl, leaderboardVisible);

  @override
  String toString() =>
      'BasicUserDto(id: $id, name: $name, username: $username, '
      'profilePictureUrl: $profilePictureUrl, '
      'leaderboardVisible: $leaderboardVisible)';
}
