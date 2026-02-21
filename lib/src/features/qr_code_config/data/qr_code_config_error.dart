sealed class QrCodeConfigError implements Exception {
  const QrCodeConfigError();
}

final class QrCodeConfigInvalidScanValueError extends QrCodeConfigError {
  const QrCodeConfigInvalidScanValueError({required this.scanValue, required this.cause});

  final String scanValue;
  final Object cause;
}

final class QrCodeConfigGenerationError extends QrCodeConfigError {
  const QrCodeConfigGenerationError({required this.cause});

  final Object cause;
}
