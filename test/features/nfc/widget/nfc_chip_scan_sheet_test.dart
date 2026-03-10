import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_availability.dart';
import 'package:pauza/src/features/nfc/widget/nfc_chip_scan_sheet.dart';

import '../../../helpers/helpers.dart';

void main() {
  testWidgets('opens NFC settings only when repository supports it', (tester) async {
    final repository = MockNfcRepository();
    when(() => repository.getAvailability()).thenAnswer((_) async => NfcChipAvailability.disabled);
    when(() => repository.canOpenSystemSettingsForNfc).thenReturn(true);
    when(() => repository.openSystemSettingsForNfc()).thenAnswer((_) async => true);

    await tester.pumpApp(
      Scaffold(
        body: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                await NfcChipScanSheet.show(context, repository: repository);
              },
              child: const Text('open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Open settings'), findsOneWidget);

    await tester.tap(find.text('Open settings'));
    await tester.pumpAndSettle();

    verify(() => repository.openSystemSettingsForNfc()).called(1);
  });

  testWidgets('falls back to OK action when repository cannot open settings', (tester) async {
    final repository = MockNfcRepository();
    when(() => repository.getAvailability()).thenAnswer((_) async => NfcChipAvailability.disabled);
    when(() => repository.canOpenSystemSettingsForNfc).thenReturn(false);

    await tester.pumpApp(
      Scaffold(
        body: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                await NfcChipScanSheet.show(context, repository: repository);
              },
              child: const Text('open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Open settings'), findsNothing);
    expect(find.text('OK'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    verifyNever(() => repository.openSystemSettingsForNfc());
  });
}
