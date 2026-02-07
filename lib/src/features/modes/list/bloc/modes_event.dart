part of 'modes_bloc.dart';

sealed class ModesListEvent extends Equatable {
  const ModesListEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class ModesListRequested extends ModesListEvent {
  const ModesListRequested();

  @override
  List<Object?> get props => <Object?>[];
}

final class ModesDeleteRequested extends ModesListEvent {
  const ModesDeleteRequested({required this.modeId});

  final String modeId;

  @override
  List<Object?> get props => <Object?>[modeId];
}

final class ModesSelectionRequested extends ModesListEvent {
  const ModesSelectionRequested({required this.modeId});

  final String modeId;

  @override
  List<Object?> get props => <Object?>[modeId];
}
