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
  const BlockingStopRequested();
}
