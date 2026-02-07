part of 'blocking_bloc.dart';

final class BlockingState extends Equatable {
  const BlockingState({this.activeModeId, this.error, this.isLoading = false});

  final String? activeModeId;
  final Object? error;
  final bool isLoading;

  bool get isBlocking => activeModeId != null;
  bool get hasError => error != null;

  BlockingState loading() => copyWith(isLoading: true);

  BlockingState setError(Object error) => copyWith(error: error, isLoading: false);

  BlockingState clearError() => copyWith(isLoading: false);

  BlockingState clearActiveModeId({bool? isLoading}) =>
      copyWith(clearActiveModeId: true, isLoading: isLoading);

  BlockingState setActiveModeId(String modeId, {bool? isLoading}) =>
      copyWith(activeModeId: modeId, isLoading: isLoading);

  BlockingState copyWith({
    String? activeModeId,
    Object? error,
    bool? isLoading,
    bool clearActiveModeId = false,
  }) {
    return BlockingState(
      activeModeId: clearActiveModeId ? null : (activeModeId ?? this.activeModeId),
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => <Object?>[activeModeId, error, isBlocking, isLoading];
}
