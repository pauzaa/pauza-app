import 'package:flutter/foundation.dart';
import 'package:pauza/src/features/friends/common/model/basic_user_dto.dart';

@immutable
final class FriendDto {
  const FriendDto({
    required this.friendshipId,
    required this.user,
    required this.since,
  });

  factory FriendDto.fromJson(Map<String, Object?> json) {
    final rawSince = json['since'] as String?;
    return FriendDto(
      friendshipId: json['friendship_id'] as String? ?? '',
      user: BasicUserDto.fromJson(json['user'] as Map<String, Object?>? ?? const {}),
      since: rawSince != null ? DateTime.parse(rawSince).toUtc() : DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  final String friendshipId;
  final BasicUserDto user;
  final DateTime since;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FriendDto &&
          friendshipId == other.friendshipId &&
          user == other.user &&
          since == other.since;

  @override
  int get hashCode => Object.hash(friendshipId, user, since);

  @override
  String toString() =>
      'FriendDto(friendshipId: $friendshipId, user: $user, since: $since)';
}
