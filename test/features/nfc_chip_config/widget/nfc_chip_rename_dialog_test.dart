import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/nfc_chip_config/widget/nfc_chip_rename_dialog.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

import '../../../helpers/helpers.dart';

void main() {
  testWidgets('save is disabled for blank input and returns trimmed value', (tester) async {
    final result = ValueNotifier<String?>(null);

    await tester.pumpApp(
      Scaffold(
        body: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                result.value = await NfcChipRenameDialog.show(context, initialName: 'Home Desk Tag');
              },
              child: const Text('open'),
            );
          },
        ),
      ),
      theme: PauzaTheme.dark,
    );

    await tester.tap(find.text('open'));
    await tester.pump();

    expect(find.text('Rename NFC Tag'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), '   ');
    await tester.pump();

    final disabledSaveButton = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Save'));
    expect(disabledSaveButton.onPressed, isNull);

    await tester.enterText(find.byType(EditableText), '  Office Door  ');
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();

    expect(result.value, 'Office Door');
  });
}
