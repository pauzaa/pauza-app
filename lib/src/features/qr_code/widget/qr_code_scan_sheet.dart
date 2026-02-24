import 'package:flutter/material.dart';
import 'package:pauza/src/features/qr_code/widget/qr_code_scan_view.dart';

class QrCodeScanSheet extends StatelessWidget {
  const QrCodeScanSheet({super.key});

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (context) => const QrCodeScanSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const QrCodeScanView();
  }
}
