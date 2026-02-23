part of 'blocking_bloc.dart';

final class BlockingState extends Equatable {
  const BlockingState({
    required this.restrictionState,
    required this.activeMode,
    this.error,
    this.actionError,
    this.isLoading = false,
  });

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
        activeMode: null,
        isLoading: true,
      );

  final RestrictionState restrictionState;
  final Mode? activeMode;
  final Object? error;
  final BlockingActionError? actionError;
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
  bool get hasActionError => actionError != null;

  BlockingState loading() => copyWith(isLoading: true, clearActionError: true);

  BlockingState setError(Object error) => copyWith(error: error, isLoading: false, clearActionError: true);

  BlockingState setActionError(BlockingActionError actionError) =>
      copyWith(actionError: actionError, isLoading: false, clearError: true);

  BlockingState clearError() => copyWith(isLoading: false, clearActionError: true);

  BlockingState setSessionState({
    required RestrictionState restrictionState,
    required Mode? activeMode,
    bool? isLoading,
  }) => copyWith(
    restrictionState: restrictionState,
    activeMode: activeMode,
    clearActiveMode: true,
    isLoading: isLoading,
    clearActionError: true,
  );

  BlockingState copyWith({
    RestrictionState? restrictionState,
    Mode? activeMode,
    bool clearActiveMode = false,
    Object? error,
    bool clearError = false,
    BlockingActionError? actionError,
    bool clearActionError = false,
    bool? isLoading,
  }) {
    return BlockingState(
      restrictionState: restrictionState ?? this.restrictionState,
      activeMode: clearActiveMode ? activeMode : (activeMode ?? this.activeMode),
      error: clearError ? null : (error ?? this.error),
      actionError: clearActionError ? null : (actionError ?? this.actionError),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    restrictionState,
    activeMode,
    sessionStartedAt,
    pausedUntil,
    error,
    actionError,
    isBlocking,
    isLoading,
  ];
}
