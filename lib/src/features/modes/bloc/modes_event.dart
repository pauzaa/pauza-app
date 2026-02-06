part of 'modes_bloc.dart';

sealed class ModesEvent extends Equatable {
  const ModesEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class ModesRequested extends ModesEvent {
  const ModesRequested({required this.platform});

  final PauzaPlatform platform;

  @override
  List<Object?> get props => <Object?>[platform];
}

final class ModesRefreshed extends ModesEvent {
  const ModesRefreshed();
}

final class ModesSelectionChanged extends ModesEvent {
  const ModesSelectionChanged({required this.modeId});

  final String modeId;

  @override
  List<Object?> get props => <Object?>[modeId];
}

final class ModesDeleteRequested extends ModesEvent {
  const ModesDeleteRequested({required this.modeId});

  final String modeId;

  @override
  List<Object?> get props => <Object?>[modeId];
}
