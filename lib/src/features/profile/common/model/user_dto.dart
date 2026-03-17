import 'package:flutter/foundation.dart';
import 'package:pauza/src/features/profile/common/model/subscription_dto.dart';

@immutable
final class UserDto {
  const UserDto({
    required this.profilePicture,
    required this.username,
    required this.name,
    this.id = '',
    this.email = '',
    this.pushEnabled = true,
    this.leaderboardVisible = true,
    this.createdAt,
    this.subscription,
  });

  factory UserDto.fromJson(Map<String, Object?> json) {
    DateTime? createdAt;
    final rawCreatedAt = json['created_at'];
    if (rawCreatedAt is String && rawCreatedAt.isNotEmpty) {
      createdAt = DateTime.tryParse(rawCreatedAt)?.toUtc();
    }

    SubscriptionDto? subscription;
    final rawSub = json['subscription'];
    if (rawSub is Map<String, Object?>) {
      subscription = SubscriptionDto.fromJson(rawSub);
    }

    return UserDto(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profilePicture: json['profile_picture_url'] as String?,
      username: json['username'] as String? ?? '',
      name: json['name'] as String? ?? '',
      pushEnabled: json['push_enabled'] as bool? ?? true,
      leaderboardVisible: json['leaderboard_visible'] as bool? ?? true,
      createdAt: createdAt,
      subscription: subscription,
    );
  }

  final String id;
  final String email;
  final String? profilePicture;
  final String username;
  final String name;
  final bool pushEnabled;
  final bool leaderboardVisible;
  final DateTime? createdAt;
  final SubscriptionDto? subscription;

  UserDto copyWith({
    String? id,
    String? email,
    String? profilePicture,
    String? username,
    String? name,
    bool? pushEnabled,
    bool? leaderboardVisible,
    DateTime? createdAt,
    SubscriptionDto? subscription,
  }) => UserDto(
    id: id ?? this.id,
    email: email ?? this.email,
    profilePicture: profilePicture ?? this.profilePicture,
    username: username ?? this.username,
    name: name ?? this.name,
    pushEnabled: pushEnabled ?? this.pushEnabled,
    leaderboardVisible: leaderboardVisible ?? this.leaderboardVisible,
    createdAt: createdAt ?? this.createdAt,
    subscription: subscription ?? this.subscription,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'email': email,
    'profile_picture_url': profilePicture,
    'username': username,
    'name': name,
    'push_enabled': pushEnabled,
    'leaderboard_visible': leaderboardVisible,
    'created_at': createdAt?.toIso8601String(),
    'subscription': subscription?.toJson(),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserDto &&
        other.id == id &&
        other.email == email &&
        other.profilePicture == profilePicture &&
        other.username == username &&
        other.name == name &&
        other.pushEnabled == pushEnabled &&
        other.leaderboardVisible == leaderboardVisible &&
        other.createdAt == createdAt &&
        other.subscription == subscription;
  }

  @override
  int get hashCode =>
      Object.hash(id, email, profilePicture, username, name, pushEnabled, leaderboardVisible, createdAt, subscription);

  @override
  String toString() =>
      'UserDto(id: $id, email: $email, profilePicture: $profilePicture, '
      'username: $username, name: $name, pushEnabled: $pushEnabled, '
      'leaderboardVisible: $leaderboardVisible, createdAt: $createdAt, '
      'subscription: $subscription)';
}
