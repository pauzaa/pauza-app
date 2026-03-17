import 'package:equatable/equatable.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';

/// High-level UI status for the profile "current user" section.
enum CurrentUserStatus {
  /// No authenticated auth session exists.
  unauthenticated,

  /// Session exists, but profile has not loaded yet.
  loading,

  /// Profile data is available.
  available,

  /// Profile could not be loaded because of a recoverable issue (for example network).
  unavailable,

  /// Profile failed with a non-recoverable/error state for UI.
  error,
}

/// Unified state model for current-user UI.
final class CurrentUserState extends Equatable {
  const CurrentUserState({required this.status, this.user, this.error, this.message});

  const CurrentUserState.unauthenticated() : this(status: CurrentUserStatus.unauthenticated);

  const CurrentUserState.loading() : this(status: CurrentUserStatus.loading);

  const CurrentUserState.available({required UserDto user}) : this(status: CurrentUserStatus.available, user: user);

  const CurrentUserState.unavailable({required Object error})
    : this(status: CurrentUserStatus.unavailable, error: error);

  const CurrentUserState.error({required Object error, String? message})
    : this(status: CurrentUserStatus.error, error: error, message: message);

  final CurrentUserStatus status;
  final UserDto? user;
  final Object? error;
  final String? message;

  /// Convenience check used in update paths where user payload is required.
  bool get isAvailable => status == CurrentUserStatus.available;

  CurrentUserState copyWith({
    CurrentUserStatus? status,
    UserDto? user,
    Object? error,
    String? message,
    bool clearError = false,
    bool clearMessage = false,
  }) {
    return CurrentUserState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: clearError ? null : error ?? this.error,
      message: clearMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, user, error, message];
}
