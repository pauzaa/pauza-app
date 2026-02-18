part of 'blocking_bloc.dart';

final class BlockingState extends Equatable {
  const BlockingState({this.activeModeId, this.sessionStartedAt, this.pausedUntil, this.error, this.isLoading = false});

  final String? activeModeId;
  final DateTime? sessionStartedAt;
  final DateTime? pausedUntil;
  final Object? error;
  final bool isLoading;

  bool get isBlocking => activeModeId != null;
  bool get isPaused => pausedUntil != null && pausedUntil!.isAfter(DateTime.now());
  bool get hasError => error != null;

  BlockingState loading() => copyWith(isLoading: true);

  BlockingState setError(Object error) => copyWith(error: error, isLoading: false);

  BlockingState clearError() => copyWith(isLoading: false);

  BlockingState clearActiveModeId({bool? isLoading}) =>
      copyWith(clearActiveModeId: true, clearSessionStartedAt: true, clearPausedUntil: true, isLoading: isLoading);

  BlockingState setSessionState({
    required String modeId,
    required DateTime? sessionStartedAt,
    required DateTime? pausedUntil,
    bool? isLoading,
  }) => copyWith(
    activeModeId: modeId,
    sessionStartedAt: sessionStartedAt,
    pausedUntil: pausedUntil,
    clearSessionStartedAt: sessionStartedAt == null,
    clearPausedUntil: pausedUntil == null,
    isLoading: isLoading,
  );

  BlockingState copyWith({
    String? activeModeId,
    DateTime? sessionStartedAt,
    DateTime? pausedUntil,
    Object? error,
    bool? isLoading,
    bool clearActiveModeId = false,
    bool clearSessionStartedAt = false,
    bool clearPausedUntil = false,
  }) {
    return BlockingState(
      activeModeId: clearActiveModeId ? null : (activeModeId ?? this.activeModeId),
      sessionStartedAt: clearSessionStartedAt ? null : (sessionStartedAt ?? this.sessionStartedAt),
      pausedUntil: clearPausedUntil ? null : (pausedUntil ?? this.pausedUntil),
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => <Object?>[activeModeId, sessionStartedAt, pausedUntil, error, isBlocking, isLoading];
}
