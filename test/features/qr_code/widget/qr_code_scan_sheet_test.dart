import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.g.dart';
import 'package:pauza/src/features/qr_code/widget/qr_code_scan_view.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

void main() {
  testWidgets('returns first detected QR value', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    String? result;

    await tester.pumpWidget(
      _TestApp(
        onOpen: (context) async {
          result = await showModalBottomSheet<String>(
            context: context,
            useRootNavigator: true,
            useSafeArea: true,
            builder: (context) {
              return QrCodeScanView(
                scannerBuilder: (context, onDetected) {
                  return TextButton(
                    onPressed: () => onDetected('  pauza:qr:v1:123e4567-e89b-42d3-a456-426614174000  '),
                    child: const Text('detect'),
                  );
                },
              );
            },
          );
        },
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('detect'));
    await tester.pumpAndSettle();

    expect(result, 'pauza:qr:v1:123e4567-e89b-42d3-a456-426614174000');
  });

  testWidgets('returns null when dismissed with cancel', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    String? result = 'pending';

    await tester.pumpWidget(
      _TestApp(
        onOpen: (context) async {
          result = await showModalBottomSheet<String>(
            context: context,
            useRootNavigator: true,
            useSafeArea: true,
            builder: (context) {
              return QrCodeScanView(
                scannerBuilder: (context, onDetected) {
                  return const SizedBox(height: 100, width: 100);
                },
              );
            },
          );
        },
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.onOpen});

  final Future<void> Function(BuildContext context) onOpen;

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
      theme: PauzaTheme.light,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                await onOpen(context);
              },
              child: const Text('open'),
            );
          },
        ),
      ),
    );
  }
}
