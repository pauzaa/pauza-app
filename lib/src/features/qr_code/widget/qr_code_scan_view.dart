import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

typedef QrCodeScannerBuilder = Widget Function(BuildContext context, ValueChanged<String> onDetected);

class QrCodeScanView extends StatefulWidget {
  const QrCodeScanView({this.scannerBuilder, super.key});

  final QrCodeScannerBuilder? scannerBuilder;

  @override
  State<QrCodeScanView> createState() => _QrCodeScanViewState();
}

class _QrCodeScanViewState extends State<QrCodeScanView> {
  late final MobileScannerController _controller;
  var _hasHandledDetection = false;

  @override
  void initState() {
    _controller = MobileScannerController(formats: const <BarcodeFormat>[BarcodeFormat.qrCode]);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetected(String rawValue) {
    if (_hasHandledDetection) {
      return;
    }

    final normalized = rawValue.trim();
    if (normalized.isEmpty) {
      return;
    }

    _hasHandledDetection = true;
    Navigator.of(context).pop(normalized);
  }

  Widget _buildDefaultScanner(BuildContext context) {
    return SizedBox(
      height: 320,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PauzaSpacing.medium),
        child: MobileScanner(
          controller: _controller,
          onDetect: (capture) {
            for (final barcode in capture.barcodes) {
              final rawValue = barcode.rawValue;
              if (rawValue != null) {
                _onDetected(rawValue);
                return;
              }
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetScaffold(
      bodyPadding: const EdgeInsets.symmetric(horizontal: PauzaSpacing.large),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: PauzaSpacing.large,
        children: <Widget>[
          Text(context.l10n.modeEndingPausingScenarioQrCode, style: Theme.of(context).textTheme.headlineLarge),
          if (widget.scannerBuilder case final scannerBuilder?)
            scannerBuilder(context, _onDetected)
          else
            _buildDefaultScanner(context),
          PauzaFilledButton(title: Text(context.l10n.cancelButton), onPressed: Navigator.of(context).pop),
        ],
      ),
    );
  }
}
