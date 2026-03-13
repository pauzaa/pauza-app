import 'package:flutter/foundation.dart';

@immutable
final class FriendMutationDto {
  const FriendMutationDto({
    required this.friendshipId,
    required this.status,
  });

  factory FriendMutationDto.fromJson(Map<String, Object?> json) =>
      FriendMutationDto(
        friendshipId: json['FriendshipID'] as String? ?? '',
        status: json['Status'] as String? ?? '',
      );

  final String friendshipId;
  final String status;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FriendMutationDto &&
          friendshipId == other.friendshipId &&
          status == other.status;

  @override
  int get hashCode => Object.hash(friendshipId, status);

  @override
  String toString() =>
      'FriendMutationDto(friendshipId: $friendshipId, status: $status)';
}
