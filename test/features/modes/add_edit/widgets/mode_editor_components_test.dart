import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_allowed_pauses_tile.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_apps_selector_tile.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_ending_pausing_scenario_panel.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_minimum_duration_tile.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_section_label.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_upsert_draft_notifier.dart';
import 'package:pauza/src/features/modes/common/model/mode_ending_pausing_scenario.dart';

import '../../../../helpers/helpers.dart';

void main() {
  testWidgets('ModeEditorSectionLabel uppercases content', (tester) async {
    await tester.pumpApp(const Scaffold(body: ModeEditorSectionLabel(label: 'Title')));

    expect(find.text('TITLE'), findsOneWidget);
  });

  testWidgets('ModeEditorAppsSelectorTile renders error text', (tester) async {
    await tester.pumpApp(
      const Scaffold(
        body: ModeEditorAppsSelectorTile(
          title: 'Select Apps',
          subtitle: 'Customize what to block',
          selectedCountLabel: '2 apps',
          errorText: 'Select at least one app',
          enabled: true,
        ),
      ),
    );

    expect(find.text('Select at least one app'), findsOneWidget);
  });

  testWidgets('ModeEditorAllowedPausesTile controls trigger callbacks', (tester) async {
    var incrementCount = 0;
    var decrementCount = 0;

    await tester.pumpApp(
      Scaffold(
        body: ModeEditorAllowedPausesTile(
          title: 'Allowed pauses',
          subtitle: 'Short breaks during session',
          value: 3,
          onIncrement: () => incrementCount += 1,
          onDecrement: () => decrementCount += 1,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();

    expect(incrementCount, 1);
    expect(decrementCount, 1);
  });

  testWidgets('ModeEditorEndingPausingScenarioPanel keeps one selected state', (tester) async {
    var selected = ModeEndingPausingScenario.manual;

    await tester.pumpApp(
      Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => ModeEditorEndingPausingScenarioPanel(
            title: 'Ending scenario',
            subtitle: 'Select one option',
            nfcLabel: 'NFC',
            qrLabel: 'QR',
            manualLabel: 'Manual',
            selectedScenario: selected,
            onScenarioPressed: (scenario) {
              setState(() {
                selected = scenario;
              });
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('QR'));
    await tester.pump();

    expect(selected, ModeEndingPausingScenario.qrCode);
  });

  testWidgets('ModeEditorEndingPausingScenarioPanel disables NFC button', (tester) async {
    await tester.pumpApp(
      const Scaffold(
        body: ModeEditorEndingPausingScenarioPanel(
          title: 'Ending scenario',
          subtitle: 'Select one option',
          nfcLabel: 'NFC',
          qrLabel: 'QR',
          manualLabel: 'Manual',
          selectedScenario: ModeEndingPausingScenario.qrCode,
          nfcDisabled: true,
          nfcDisabledHint: 'NFC unavailable',
          onScenarioPressed: _noopScenarioPressed,
        ),
      ),
    );

    await tester.tap(find.text('NFC'));
    await tester.pump();

    expect(find.text('NFC unavailable'), findsOneWidget);
  });

  testWidgets('ModeEditorMinimumDurationTile shows value and clear action', (tester) async {
    final draftNotifier = ModeUpsertDraftNotifier(hasNfcSupport: true);
    draftNotifier.updateMinimumDuration(const Duration(minutes: 20));

    await tester.pumpApp(
      Scaffold(
        body: ModeUpsertScope(
          notifier: draftNotifier,
          child: const ModeEditorMinimumDurationTile(
            title: 'Minimum duration',
            subtitle: 'Optional',
            duration: Duration(minutes: 20),
            actionLabel: 'Set',
            clearLabel: 'Clear',
            enabled: true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Clear'));
    await tester.pump();

    expect(find.text('20 min'), findsOneWidget);
    expect(draftNotifier.value.minimumDuration, isNull);
  });
}

void _noopScenarioPressed(ModeEndingPausingScenario _) {}
