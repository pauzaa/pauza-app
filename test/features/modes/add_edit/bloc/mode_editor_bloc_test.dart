import 'package:bloc_test/bloc_test.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pauza/src/features/modes/add_edit/bloc/mode_editor_bloc.dart';
import 'package:pauza/src/features/modes/common/model/mode_icon.dart';
import 'package:pauza/src/features/modes/common/model/mode_upsert.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late MockModesRepository repository;

  setUpAll(registerTestFallbackValues);

  setUp(() {
    repository = MockModesRepository();
  });

  group('ModeEditorBloc', () {
    blocTest<ModeEditorBloc, ModeEditorState>(
      'save create calls repository createMode',
      setUp: () {
        when(() => repository.createMode(any())).thenAnswer((_) async {});
      },
      build: () => ModeEditorBloc(modesRepository: repository, hasNfcSupport: true),
      act: (bloc) {
        final request = makeModeUpsertDto(
          title: 'Deep Work',
          textOnScreen: 'Stay focused',
          blockedAppIds: const ISetConst<AppIdentifier>(<AppIdentifier>{}),
        );
        bloc.add(ModeEditorSaveRequested(modeId: null, request: request));
      },
      expect: () => <Matcher>[isA<ModeEditorLoading>(), isA<ModeEditorSaveSuccess>()],
      verify: (_) {
        final captured = verify(() => repository.createMode(captureAny())).captured.single as ModeUpsertDTO;
        expect(captured.title, 'Deep Work');
      },
    );

    blocTest<ModeEditorBloc, ModeEditorState>(
      'delete success emits ModeEditorDeleteSuccess',
      setUp: () {
        when(() => repository.deleteMode(any())).thenAnswer((_) async {});
      },
      build: () => ModeEditorBloc(modesRepository: repository, hasNfcSupport: true),
      act: (bloc) => bloc.add(const ModeEditorDeleteRequested(modeId: 'mode-1')),
      expect: () => <Matcher>[isA<ModeEditorLoading>(), isA<ModeEditorDeleteSuccess>()],
      verify: (_) {
        verify(() => repository.deleteMode('mode-1')).called(1);
      },
    );

    blocTest<ModeEditorBloc, ModeEditorState>(
      'delete with null id emits failure',
      build: () => ModeEditorBloc(modesRepository: repository, hasNfcSupport: true),
      act: (bloc) => bloc.add(const ModeEditorDeleteRequested(modeId: null)),
      expect: () => <Matcher>[isA<ModeEditorLoading>(), isA<ModeEditorFailure>()],
    );

    blocTest<ModeEditorBloc, ModeEditorState>(
      'load maps mode icon token to request icon token',
      setUp: () {
        when(() => repository.getMode(any())).thenAnswer((_) async => makeMode());
      },
      build: () => ModeEditorBloc(modesRepository: repository, hasNfcSupport: true),
      act: (bloc) => bloc.add(const ModeEditorLoadRequested(modeId: 'mode-1')),
      expect: () => <Matcher>[
        isA<ModeEditorLoading>(),
        isA<ModeEditorReady>().having((s) => s.request.icon, 'request.icon', ModeIconCatalog.defaultIcon),
      ],
      verify: (_) {
        verify(() => repository.getMode('mode-1')).called(1);
      },
    );
  });
}
