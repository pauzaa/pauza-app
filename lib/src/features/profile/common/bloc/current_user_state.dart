import 'package:equatable/equatable.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';
import 'package:pauza/src/features/profile/common/model/user_profile_failure.dart';

/// High-level UI status for the profile "current user" section.
enum CurrentUserStatus {
  /// No authenticated auth session exists.
  unauthenticated,

  /// Session exists, but there is no cached profile yet.
  loading,

  /// Profile data is available (fresh or stale).
  available,

  /// Profile could not be loaded because of a recoverable issue (for example network).
  unavailable,

  /// Profile failed with a non-recoverable/error state for UI.
  error,
}

/// Freshness of cached profile payload relative to TTL.
enum UserFreshness { fresh, stale, unknown }

/// Unified state model for current-user UI.
///
/// We keep one state object with [status] plus optional fields instead of many
/// subclasses to simplify transitions and rendering.
final class CurrentUserState extends Equatable {
  const CurrentUserState({
    required this.status,
    this.user,
    this.freshness = UserFreshness.unknown,
    this.cachedAtUtc,
    this.isSyncing = false,
    this.reason,
    this.message,
  });

  const CurrentUserState.unauthenticated()
    : this(status: CurrentUserStatus.unauthenticated);

  const CurrentUserState.loading() : this(status: CurrentUserStatus.loading);

  const CurrentUserState.available({
    required UserDto user,
    required UserFreshness freshness,
    required DateTime cachedAtUtc,
    required bool isSyncing,
  }) : this(
         status: CurrentUserStatus.available,
         user: user,
         freshness: freshness,
         cachedAtUtc: cachedAtUtc,
         isSyncing: isSyncing,
       );

  const CurrentUserState.unavailable({required UserProfileFailureCode reason})
    : this(status: CurrentUserStatus.unavailable, reason: reason);

  const CurrentUserState.error({
    required UserProfileFailureCode reason,
    String? message,
  }) : this(status: CurrentUserStatus.error, reason: reason, message: message);

  final CurrentUserStatus status;
  final UserDto? user;
  final UserFreshness freshness;
  final DateTime? cachedAtUtc;
  final bool isSyncing;
  final UserProfileFailureCode? reason;
  final String? message;

  /// Convenience check used in update paths where user payload is required.
  bool get isAvailable => status == CurrentUserStatus.available;

  /// Partial update helper for transition logic.
  ///
  /// [clearReason]/[clearMessage] let us explicitly reset failure details when
  /// moving to a non-error status.
  CurrentUserState copyWith({
    CurrentUserStatus? status,
    UserDto? user,
    UserFreshness? freshness,
    DateTime? cachedAtUtc,
    bool? isSyncing,
    UserProfileFailureCode? reason,
    String? message,
    bool clearReason = false,
    bool clearMessage = false,
  }) {
    return CurrentUserState(
      status: status ?? this.status,
      user: user ?? this.user,
      freshness: freshness ?? this.freshness,
      cachedAtUtc: cachedAtUtc ?? this.cachedAtUtc,
      isSyncing: isSyncing ?? this.isSyncing,
      reason: clearReason ? null : reason ?? this.reason,
      message: clearMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    user,
    freshness,
    cachedAtUtc,
    isSyncing,
    reason,
    message,
  ];
}
