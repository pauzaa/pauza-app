part of 'blocking_bloc.dart';

final class BlockingState extends Equatable {
  const BlockingState({required this.restrictionState, this.error, this.isLoading = false});

  const BlockingState.initial()
    : this(
        restrictionState: const RestrictionState(
          activeMode: null,
          activeModeSource: RestrictionModeSource.none,
          currentSessionEvents: [],
          isInScheduleNow: false,
          isScheduleEnabled: false,
          pausedUntil: null,
        ),
        isLoading: true,
      );

  final RestrictionState restrictionState;
  final Object? error;
  final bool isLoading;

  bool get isBlocking => restrictionState.isActiveNow;
  bool get isPaused => restrictionState.isPausedNow;
  DateTime? get pauseStartedAt => restrictionState.activePauseStartedAt;
  Duration? get pauseTotalDuration => pausedUntil?.difference(pauseStartedAt ?? DateTime.now());
  DateTime? get sessionStartedAt => restrictionState.startedAt;
  Duration? get pauseDuration => pauseStartedAt?.difference(DateTime.now()).abs();
  Duration? get pauseRemainingDuration => pauseTotalDuration != null ? pauseTotalDuration! - pauseDuration! : null;
  DateTime? get pausedUntil => restrictionState.pausedUntil;
  Duration? get sessionDuration => restrictionState.startedAt?.difference(DateTime.now());
  bool get hasError => error != null;

  BlockingState loading() => copyWith(isLoading: true);

  BlockingState setError(Object error) => copyWith(error: error, isLoading: false);

  BlockingState clearError() => copyWith(isLoading: false);

  BlockingState setSessionState({required RestrictionState restrictionState, bool? isLoading}) =>
      copyWith(restrictionState: restrictionState, isLoading: isLoading);

  BlockingState copyWith({RestrictionState? restrictionState, Object? error, bool? isLoading}) {
    return BlockingState(
      restrictionState: restrictionState ?? this.restrictionState,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => <Object?>[restrictionState, sessionStartedAt, pausedUntil, error, isBlocking, isLoading];
}
