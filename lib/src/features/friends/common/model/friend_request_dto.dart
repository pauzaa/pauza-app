import 'package:flutter/foundation.dart';
import 'package:pauza/src/features/friends/common/model/basic_user_dto.dart';

@immutable
final class FriendRequestDto {
  const FriendRequestDto({
    required this.friendshipId,
    required this.user,
    required this.createdAt,
  });

  factory FriendRequestDto.fromJson(Map<String, Object?> json) {
    final rawCreatedAt = json['CreatedAt'] as String?;
    return FriendRequestDto(
      friendshipId: json['FriendshipID'] as String? ?? '',
      user: BasicUserDto.fromJson(json['User'] as Map<String, Object?>? ?? const {}),
      createdAt: rawCreatedAt != null
          ? DateTime.parse(rawCreatedAt).toUtc()
          : DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  final String friendshipId;
  final BasicUserDto user;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FriendRequestDto &&
          friendshipId == other.friendshipId &&
          user == other.user &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(friendshipId, user, createdAt);

  @override
  String toString() =>
      'FriendRequestDto(friendshipId: $friendshipId, user: $user, '
      'createdAt: $createdAt)';
}
