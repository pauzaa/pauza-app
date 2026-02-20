import 'package:flutter/foundation.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';

@immutable
final class CachedUserProfile {
  const CachedUserProfile({required this.user, required this.cachedAtUtc});

  factory CachedUserProfile.fromJson(Map<String, Object?> json) {
    final userJson = json['user'];
    final cachedAtUtcMs = json['cachedAtUtcMs'];
    if (userJson is! Map<String, Object?> || cachedAtUtcMs is! int) {
      throw const FormatException('Invalid cached user payload');
    }

    return CachedUserProfile(
      user: UserDto.fromJson(userJson),
      cachedAtUtc: DateTime.fromMillisecondsSinceEpoch(cachedAtUtcMs, isUtc: true),
    );
  }

  final UserDto user;
  final DateTime cachedAtUtc;

  bool isFresh({required DateTime nowUtc, required Duration ttl}) {
    if (cachedAtUtc.isAfter(nowUtc)) {
      return false;
    }
    return nowUtc.difference(cachedAtUtc) <= ttl;
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{'user': user.toJson(), 'cachedAtUtcMs': cachedAtUtc.toUtc().millisecondsSinceEpoch};
  }

  @override
  String toString() {
    return 'CachedUserProfile(user: $user, cachedAtUtc: $cachedAtUtc)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is CachedUserProfile && other.user == user && other.cachedAtUtc == cachedAtUtc;
  }

  @override
  int get hashCode => Object.hash(user, cachedAtUtc);
}
