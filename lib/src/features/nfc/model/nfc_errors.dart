import 'package:flutter/material.dart';

enum NfcErrorCode {
  unsupported,
  disabled,
  busy,
  permissionDenied,
  timeout,
  cancelled,
  unknown,
}

@immutable
class NfcException implements Exception {
  const NfcException({required this.code, required this.message, this.cause});

  final NfcErrorCode code;
  final String message;
  final Object? cause;

  @override
  String toString() {
    return 'NfcException(code: $code, message: $message, cause: $cause)';
  }
}
