import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pauza/src/features/modes/add_edit/bloc/mode_editor_bloc.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_icon_picker.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_screen.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late MockModesRepository modesRepository;

  setUp(() {
    modesRepository = MockModesRepository();
    when(() => modesRepository.getModes()).thenAnswer((_) async => []);
    when(() => modesRepository.getMode(any())).thenAnswer(
      (_) async => makeMode(
        title: 'Deep Work',
        textOnScreen: 'Stay focused',
        description: 'desc',
        allowedPausesCount: 2,
        blockedAppIds: const ISet.empty(),
      ),
    );
    when(() => modesRepository.createMode(any())).thenAnswer((_) async {});
    when(
      () => modesRepository.updateMode(
        modeId: any(named: 'modeId'),
        request: any(named: 'request'),
      ),
    ).thenAnswer((_) async {});
    when(() => modesRepository.deleteMode(any())).thenAnswer((_) async {});
  });

  setUpAll(registerTestFallbackValues);

  testWidgets('delete button appears only in edit mode', (tester) async {
    final createBloc = ModeEditorBloc(modesRepository: modesRepository, hasNfcSupport: true);
    addTearDown(createBloc.close);
    await tester.pumpApp(
      BlocProvider<ModeEditorBloc>.value(
        value: createBloc,
        child: const ModeEditorMainScreen(modeId: null, hasNfcSupport: true),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Delete Focus Mode'), findsNothing);

    final editBloc = ModeEditorBloc(modesRepository: modesRepository, hasNfcSupport: true);
    addTearDown(editBloc.close);
    await tester.pumpApp(
      BlocProvider<ModeEditorBloc>.value(
        value: editBloc,
        child: const ModeEditorMainScreen(modeId: 'mode-1', hasNfcSupport: true),
      ),
    );
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text('Delete Focus Mode').evaluate().isNotEmpty) {
        break;
      }
    }

    await tester.drag(find.byType(ListView), const Offset(0, -1000));
    await tester.pump();

    expect(find.text('Delete Focus Mode'), findsOneWidget);
  });

  testWidgets('save with empty fields shows notifier validation errors', (tester) async {
    final bloc = ModeEditorBloc(modesRepository: modesRepository, hasNfcSupport: true);
    addTearDown(bloc.close);
    await tester.pumpApp(
      BlocProvider<ModeEditorBloc>.value(
        value: bloc,
        child: const ModeEditorMainScreen(modeId: null, hasNfcSupport: true),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Save Mode'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('This field is required'), findsAtLeastNWidgets(1));
  });

  testWidgets('renders icon picker at top', (tester) async {
    final bloc = ModeEditorBloc(modesRepository: modesRepository, hasNfcSupport: true);
    addTearDown(bloc.close);
    await tester.pumpApp(
      BlocProvider<ModeEditorBloc>.value(
        value: bloc,
        child: const ModeEditorMainScreen(modeId: null, hasNfcSupport: true),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    // Icon picker is visible at the top (in the Row with title field)
    expect(find.byType(ModeEditorIconPicker), findsOneWidget);
  });
}
