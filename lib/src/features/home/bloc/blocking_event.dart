part of 'blocking_bloc.dart';

sealed class BlockingEvent extends Equatable {
  const BlockingEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class BlockingSyncRequested extends BlockingEvent {
  const BlockingSyncRequested();
}

final class BlockingStartRequested extends BlockingEvent {
  const BlockingStartRequested(this.mode);

  final Mode mode;

  @override
  List<Object?> get props => <Object?>[mode];
}

final class BlockingStopRequested extends BlockingEvent {
  const BlockingStopRequested({this.proof});

  final BlockingActionProof? proof;

  @override
  List<Object?> get props => <Object?>[proof];
}

final class BlockingQuickPauseRequested extends BlockingEvent {
  const BlockingQuickPauseRequested(this.duration, {this.proof});

  final Duration duration;
  final BlockingActionProof? proof;

  @override
  List<Object?> get props => <Object?>[duration, proof];
}

final class BlockingResumeRequested extends BlockingEvent {
  const BlockingResumeRequested();
}
