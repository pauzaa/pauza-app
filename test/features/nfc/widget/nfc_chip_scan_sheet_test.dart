import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.g.dart';
import 'package:pauza/src/features/nfc/data/nfc_repository.dart';
import 'package:pauza/src/features/nfc/model/nfc_card_dto.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_availability.dart';
import 'package:pauza/src/features/nfc/widget/nfc_chip_scan_sheet.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

void main() {
  testWidgets('opens NFC settings only when repository supports it', (tester) async {
    final repository = _FakeNfcRepository(
      availability: NfcChipAvailability.disabled,
      canOpenSystemSettingsForNfc: true,
    );

    await tester.pumpWidget(_TestApp(repository: repository));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Open settings'), findsOneWidget);

    await tester.tap(find.text('Open settings'));
    await tester.pumpAndSettle();

    expect(repository.openSystemSettingsCalls, 1);
  });

  testWidgets('falls back to OK action when repository cannot open settings', (tester) async {
    final repository = _FakeNfcRepository(
      availability: NfcChipAvailability.disabled,
      canOpenSystemSettingsForNfc: false,
    );

    await tester.pumpWidget(_TestApp(repository: repository));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Open settings'), findsNothing);
    expect(find.text('OK'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(repository.openSystemSettingsCalls, 0);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.repository});

  final NfcRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: PauzaTheme.dark,
      home: Scaffold(
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
  }
}

final class _FakeNfcRepository implements NfcRepository {
  _FakeNfcRepository({required this.availability, required this.canOpenSystemSettingsForNfc});

  final NfcChipAvailability availability;

  @override
  final bool canOpenSystemSettingsForNfc;

  var openSystemSettingsCalls = 0;

  @override
  bool get isScanInProgress => false;

  @override
  Future<NfcChipAvailability> getAvailability() async => availability;

  @override
  Future<bool> openSystemSettingsForNfc() async {
    openSystemSettingsCalls += 1;
    return true;
  }

  @override
  Future<NfcCardDto> scanSingleCard({Duration timeout = const Duration(seconds: 20)}) {
    throw UnimplementedError();
  }

  @override
  Future<void> stopSession({String? alertMessage, String? errorMessage}) async {}
}
