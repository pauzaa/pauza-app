import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.g.dart';
import 'package:pauza/src/features/qr_code_config/model/qr_linked_code.dart';
import 'package:pauza/src/features/qr_code_config/model/qr_unlock_token.dart';
import 'package:pauza/src/features/qr_code_config/widget/qr_code_preview_dialog.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  testWidgets('renders QR image with normalized scan value', (tester) async {
    final code = QrLinkedCode(
      id: 'code-1',
      scanValue: QrUnlockToken.parse('PAUZA:QR:V1:3F2504E0-4F89-41D3-9A0C-0305E82C3301'),
      name: 'Office QR',
      createdAt: DateTime.utc(2023, 10, 24),
      updatedAt: DateTime.utc(2023, 10, 24),
    );

    await tester.pumpWidget(
      MaterialApp(
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
                onPressed: () => QrCodePreviewDialog.show(context, code: code),
                child: const Text('open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();

    expect(find.text('QR Code Preview'), findsOneWidget);
    expect(find.text('Office QR'), findsOneWidget);

    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text('pauza:qr:v1:3f2504e0-4f89-41d3-9a0c-0305e82c3301'), findsOneWidget);
  });
}
