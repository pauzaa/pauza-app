import 'package:flutter/material.dart';

@immutable
class NfcNdefRecordDto {
  const NfcNdefRecordDto({
    required this.tnf,
    required this.typeHex,
    required this.identifierHex,
    required this.payloadHex,
    required this.payloadText,
  });

  final String tnf;
  final String typeHex;
  final String identifierHex;
  final String payloadHex;
  final String? payloadText;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'tnf': tnf,
      'typeHex': typeHex,
      'identifierHex': identifierHex,
      'payloadHex': payloadHex,
      'payloadText': payloadText,
    };
  }

  factory NfcNdefRecordDto.fromJson(Map<String, Object?> json) {
    return NfcNdefRecordDto(
      tnf: json['tnf'] as String? ?? '',
      typeHex: json['typeHex'] as String? ?? '',
      identifierHex: json['identifierHex'] as String? ?? '',
      payloadHex: json['payloadHex'] as String? ?? '',
      payloadText: json['payloadText'] as String?,
    );
  }

  @override
  String toString() {
    return 'NfcNdefRecordDto('
        'tnf: $tnf, '
        'typeHex: $typeHex, '
        'identifierHex: $identifierHex, '
        'payloadHex: $payloadHex, '
        'payloadText: $payloadText'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is NfcNdefRecordDto &&
        other.tnf == tnf &&
        other.typeHex == typeHex &&
        other.identifierHex == identifierHex &&
        other.payloadHex == payloadHex &&
        other.payloadText == payloadText;
  }

  @override
  int get hashCode => Object.hash(tnf, typeHex, identifierHex, payloadHex, payloadText);
}
