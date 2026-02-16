part of 'current_user_bloc.dart';

sealed class CurrentUserEvent {
  const CurrentUserEvent();
}

/// Emitted whenever auth session changes.
///
/// This is the entry point for session-driven profile state updates.
final class CurrentUserSessionChanged extends CurrentUserEvent {
  const CurrentUserSessionChanged({required this.session});

  final Session session;
}

/// Requests profile refresh from remote source.
///
/// [forceRemote] skips freshness short-circuit checks.
final class CurrentUserRefreshRequested extends CurrentUserEvent {
  const CurrentUserRefreshRequested({required this.forceRemote});

  final bool forceRemote;
}
