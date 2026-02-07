part of 'mode_editor_bloc.dart';

sealed class ModeEditorState extends Equatable {
  const ModeEditorState();

  @override
  List<Object?> get props => const <Object?>[];
}

final class ModeEditorInitial extends ModeEditorState {
  const ModeEditorInitial();
}

final class ModeEditorLoading extends ModeEditorState {
  const ModeEditorLoading();

  @override
  List<Object?> get props => const <Object?>[];
}

final class ModeEditorReady extends ModeEditorState {
  const ModeEditorReady({required this.modeId, required this.request});

  final String? modeId;
  final ModeUpsertDTO request;

  @override
  List<Object?> get props => <Object?>[modeId, request];
}

final class ModeEditorSaveSuccess extends ModeEditorState {
  const ModeEditorSaveSuccess({required this.modeId, required this.request});

  final String? modeId;
  final ModeUpsertDTO request;

  @override
  List<Object?> get props => <Object?>[modeId, request];
}

final class ModeEditorFailure extends ModeEditorState {
  const ModeEditorFailure(this.error);

  final Object error;

  @override
  List<Object?> get props => <Object?>[error];
}
