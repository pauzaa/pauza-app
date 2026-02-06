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
  const BlockingStartRequested({required this.modeId, required this.platform});

  final String modeId;
  final PauzaPlatform platform;

  @override
  List<Object?> get props => <Object?>[modeId, platform];
}

final class BlockingStopRequested extends BlockingEvent {
  const BlockingStopRequested();
}
