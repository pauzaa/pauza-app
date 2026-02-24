import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

/// Mixin that renders a QR code to a PNG and shares it via the system share
/// sheet, with a built-in in-flight guard.
///
/// Classes that mix this in can override [onSharingStateChanged] to react to
/// state transitions (e.g. calling `setState` to update UI).
mixin QrCodeSharer {
  static const double _qrExportSize = 1024;
  static const double _qrExportPadding = 96;

  bool _isSharing = false;

  /// Whether a share operation is currently in progress.
  bool get isSharing => _isSharing;

  /// Called whenever [isSharing] transitions between `true` and `false`.
  /// Override to trigger a UI rebuild.
  void onSharingStateChanged() {}

  /// Renders [scanValue] as a QR PNG and opens the system share sheet.
  ///
  /// Returns `false` (and does nothing) if a share is already in flight.
  Future<bool> shareQrCode({required String scanValue, required String codeName, required String codeId}) async {
    if (_isSharing) return false;

    _isSharing = true;
    onSharingStateChanged();
    try {
      final imageBytes = await _createQrImageBytes(scanValue);
      final temporaryDirectory = await getTemporaryDirectory();
      final fileName = _buildFileName(codeName: codeName, codeId: codeId);
      final file = File('${temporaryDirectory.path}/$fileName');
      await file.writeAsBytes(imageBytes, flush: true);
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path, mimeType: 'image/png')]));
      return true;
    } finally {
      _isSharing = false;
      onSharingStateChanged();
    }
  }

  static Future<Uint8List> _createQrImageBytes(String scanValue) async {
    final painter = QrPainter(data: scanValue, version: QrVersions.auto, gapless: true);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const exportSize = Size.square(_qrExportSize);
    canvas.drawRect(Offset.zero & exportSize, Paint()..color = const Color(0xFFFFFFFF));
    canvas.save();
    canvas.translate(_qrExportPadding, _qrExportPadding);
    painter.paint(canvas, const Size.square(_qrExportSize - (_qrExportPadding * 2)));
    canvas.restore();
    final image = await recorder.endRecording().toImage(_qrExportSize.toInt(), _qrExportSize.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Unable to build QR image bytes.');
    }
    return byteData.buffer.asUint8List();
  }

  static String _buildFileName({required String codeName, required String codeId}) {
    final sanitizedName = codeName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final effectiveName = sanitizedName.isEmpty ? 'qr_code' : sanitizedName;
    return '${effectiveName}_$codeId.png';
  }
}
