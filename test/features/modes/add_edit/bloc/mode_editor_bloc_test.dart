import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/modes/add_edit/bloc/mode_editor_bloc.dart';
import 'package:pauza/src/features/modes/common/data/modes_repository.dart';
import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:pauza/src/features/modes/common/model/mode_icon.dart';
import 'package:pauza/src/features/modes/common/model/mode_upsert.dart';

void main() {
  group('ModeEditorBloc', () {
    test('save create calls repository createMode', () async {
      final repository = _FakeModesRepository();
      final bloc = ModeEditorBloc(modesRepository: repository);

      final request = const ModeUpsertDTO.initial().copyWith(
        title: 'Deep Work',
        textOnScreen: 'Stay focused',
        blockedAppIds: const ISet.empty(),
      );

      bloc.add(ModeEditorSaveRequested(modeId: null, request: request));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(repository.createdRequests, hasLength(1));
      expect(repository.createdRequests.single.title, 'Deep Work');

      await bloc.close();
    });

    test('delete success emits ModeEditorDeleteSuccess', () async {
      final repository = _FakeModesRepository();
      final bloc = ModeEditorBloc(modesRepository: repository);
      final emitted = <ModeEditorState>[];
      final sub = bloc.stream.listen(emitted.add);

      bloc.add(const ModeEditorDeleteRequested(modeId: 'mode-1'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(repository.deletedModeIds, <String>['mode-1']);
      expect(emitted.whereType<ModeEditorDeleteSuccess>(), isNotEmpty);

      await sub.cancel();
      await bloc.close();
    });

    test('delete with null id emits failure', () async {
      final repository = _FakeModesRepository();
      final bloc = ModeEditorBloc(modesRepository: repository);
      final emitted = <ModeEditorState>[];
      final sub = bloc.stream.listen(emitted.add);

      bloc.add(const ModeEditorDeleteRequested(modeId: null));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(emitted.last, isA<ModeEditorFailure>());

      await sub.cancel();
      await bloc.close();
    });

    test('load maps mode icon token to request icon token', () async {
      final repository = _FakeModesRepository();
      final bloc = ModeEditorBloc(modesRepository: repository);
      final emitted = <ModeEditorState>[];
      final sub = bloc.stream.listen(emitted.add);

      bloc.add(const ModeEditorLoadRequested(modeId: 'mode-1'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final ready = emitted.whereType<ModeEditorReady>().last;
      expect(ready.request.icon, ModeIconCatalog.defaultIcon);

      await sub.cancel();
      await bloc.close();
    });
  });
}

class _FakeModesRepository implements ModesRepository {
  final List<ModeUpsertDTO> createdRequests = <ModeUpsertDTO>[];
  final List<String> deletedModeIds = <String>[];

  @override
  Future<void> createMode(ModeUpsertDTO request) async {
    createdRequests.add(request);
  }

  @override
  Future<void> deleteMode(String modeId) async {
    deletedModeIds.add(modeId);
  }

  @override
  Future<Mode> getMode(String modeId) async {
    return Mode(
      id: modeId,
      title: 'Focus',
      textOnScreen: 'Stay focused',
      description: null,
      allowedPausesCount: 2,
      icon: ModeIconCatalog.defaultIcon,
      schedule: null,
      blockedAppIds: const ISet.empty(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<List<Mode>> getModes() async => <Mode>[];

  @override
  Future<void> updateMode({required String modeId, required ModeUpsertDTO request}) async {}

  @override
  Stream<void> watchModes() => const Stream.empty();

  @override
  void dispose() {}
}
