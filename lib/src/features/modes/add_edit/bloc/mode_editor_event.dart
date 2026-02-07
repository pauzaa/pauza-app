part of 'mode_editor_bloc.dart';

sealed class ModeEditorEvent extends Equatable {
  const ModeEditorEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class ModeEditorLoadRequested extends ModeEditorEvent {
  const ModeEditorLoadRequested({required this.modeId});

  final String? modeId;

  @override
  List<Object?> get props => <Object?>[modeId];
}

final class ModeEditorSaveRequested extends ModeEditorEvent {
  const ModeEditorSaveRequested({required this.modeId, required this.request});
  final String? modeId;
  final ModeUpsertDTO request;

  @override
  List<Object?> get props => <Object?>[request];
}
