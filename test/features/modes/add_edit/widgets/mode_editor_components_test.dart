import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_allowed_pauses_tile.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_apps_selector_tile.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_section_label.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

void main() {
  testWidgets('ModeEditorSectionLabel uppercases content', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: PauzaTheme.dark,
        home: const Scaffold(body: ModeEditorSectionLabel(label: 'Title')),
      ),
    );

    expect(find.text('TITLE'), findsOneWidget);
  });

  testWidgets('ModeEditorAppsSelectorTile renders error text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: PauzaTheme.dark,
        home: Scaffold(
          body: ModeEditorAppsSelectorTile(
            title: 'Select Apps',
            subtitle: 'Customize what to block',
            selectedCountLabel: '2 apps',
            errorText: 'Select at least one app',
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Select at least one app'), findsOneWidget);
  });

  testWidgets('ModeEditorAllowedPausesTile controls trigger callbacks', (tester) async {
    var incrementCount = 0;
    var decrementCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: PauzaTheme.dark,
        home: Scaffold(
          body: ModeEditorAllowedPausesTile(
            title: 'Allowed pauses',
            subtitle: 'Short breaks during session',
            value: 3,
            onIncrement: () => incrementCount += 1,
            onDecrement: () => decrementCount += 1,
          ),
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
}
