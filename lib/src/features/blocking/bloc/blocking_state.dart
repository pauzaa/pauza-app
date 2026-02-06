part of 'blocking_bloc.dart';

enum BlockingStatus { idle, starting, active, stopping, failure }

final class BlockingState extends Equatable {
  const BlockingState({
    this.status = BlockingStatus.idle,
    this.activeModeId,
    this.errorMessage,
  });

  final BlockingStatus status;
  final String? activeModeId;
  final String? errorMessage;

  bool get isBlocking => switch (status) {
    BlockingStatus.starting ||
    BlockingStatus.active ||
    BlockingStatus.stopping => true,
    BlockingStatus.idle || BlockingStatus.failure => false,
  };

  BlockingState copyWith({
    BlockingStatus? status,
    String? activeModeId,
    bool clearActiveModeId = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BlockingState(
      status: status ?? this.status,
      activeModeId: clearActiveModeId
          ? null
          : (activeModeId ?? this.activeModeId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[status, activeModeId, errorMessage];
}
