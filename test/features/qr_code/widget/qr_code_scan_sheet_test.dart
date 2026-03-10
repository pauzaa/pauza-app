import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/qr_code/widget/qr_code_scan_view.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

import '../../../helpers/helpers.dart';

void main() {
  testWidgets('returns first detected QR value', (tester) async {
    String? result;

    await tester.pumpApp(
      Scaffold(
        body: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
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
              child: const Text('open'),
            );
          },
        ),
      ),
      theme: PauzaTheme.light,
      surfaceSize: const Size(1200, 3000),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('detect'));
    await tester.pumpAndSettle();

    expect(result, 'pauza:qr:v1:123e4567-e89b-42d3-a456-426614174000');
  });

  testWidgets('returns null when dismissed with cancel', (tester) async {
    String? result = 'pending';

    await tester.pumpApp(
      Scaffold(
        body: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
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
              child: const Text('open'),
            );
          },
        ),
      ),
      theme: PauzaTheme.light,
      surfaceSize: const Size(1200, 3000),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });
}
