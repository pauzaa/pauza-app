import 'dart:convert';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:nfc_util/nfc_util.dart';
import 'package:nfc_util/platform_tags.dart';
import 'package:pauza/src/features/nfc/model/nfc_ndef_record_dto.dart';
import 'package:pauza/src/features/nfc/model/nfc_tag_tech.dart';

enum NfcPlatformAvailability { available, disabled, notSupported, unknown }

@immutable
class NfcTagSnapshot {
  const NfcTagSnapshot({
    required this.uidHex,
    required this.techTypes,
    required this.isNdefFormatted,
    required this.ndefRecords,
    required this.rawSnapshot,
  });

  final String? uidHex;
  final bool isNdefFormatted;
  final IList<NfcTagTech> techTypes;
  final IList<NfcNdefRecordDto> ndefRecords;
  final IMap<String, Object?> rawSnapshot;

  static Future<NfcTagSnapshot> mapNfcTagSnapshotFromUtilTag(NfcTag tag) async {
    final techTypes = _extractTechTypes(tag);
    final uidHex = _extractUidHex(tag);
    final ndefRecords = await _extractNdefRecords(tag);

    final rawSnapshot = <String, Object?>{
      'uidHex': uidHex,
      'techTypes': techTypes.map((tech) => tech.name).toList(growable: false),
      'platform': defaultTargetPlatform.name,
      'rawTagData': _normalizeRawValue(tag.data),
    };

    return NfcTagSnapshot(
      uidHex: uidHex,
      techTypes: techTypes.lock,
      isNdefFormatted: ndefRecords.isNotEmpty || Ndef.from(tag) != null,
      ndefRecords: ndefRecords.lock,
      rawSnapshot: rawSnapshot.lock,
    );
  }
}

List<NfcTagTech> _extractTechTypes(NfcTag tag) {
  final types = <NfcTagTech>[];

  for (final key in tag.data.keys) {
    final mapped = NfcTagTech.fromPlatformKey(key);
    if (mapped != NfcTagTech.unknown && !types.contains(mapped)) {
      types.add(mapped);
    }
  }

  if (Ndef.from(tag) != null) {
    _addIfMissing(types, NfcTagTech.ndef);
  }
  if (NfcA.from(tag) != null) {
    _addIfMissing(types, NfcTagTech.nfcA);
  }
  if (NfcB.from(tag) != null) {
    _addIfMissing(types, NfcTagTech.nfcB);
  }
  if (NfcF.from(tag) != null) {
    _addIfMissing(types, NfcTagTech.nfcF);
    _addIfMissing(types, NfcTagTech.felica);
  }
  if (NfcV.from(tag) != null) {
    _addIfMissing(types, NfcTagTech.nfcV);
    _addIfMissing(types, NfcTagTech.iso15693);
  }
  if (IsoDep.from(tag) != null) {
    _addIfMissing(types, NfcTagTech.isoDep);
  }
  if (Iso7816.from(tag) != null) {
    _addIfMissing(types, NfcTagTech.iso7816);
  }
  if (Iso15693.from(tag) != null) {
    _addIfMissing(types, NfcTagTech.iso15693);
  }
  if (FeliCa.from(tag) != null) {
    _addIfMissing(types, NfcTagTech.felica);
  }
  if (MifareClassic.from(tag) != null) {
    _addIfMissing(types, NfcTagTech.mifareClassic);
  }
  if (MifareUltralight.from(tag) != null) {
    _addIfMissing(types, NfcTagTech.mifareUltralight);
  }

  if (types.isEmpty) {
    types.add(NfcTagTech.unknown);
  }

  return types;
}

String? _extractUidHex(NfcTag tag) {
  final iosMifare = MiFare.from(tag);
  if (iosMifare != null) {
    return _bytesToHex(iosMifare.identifier);
  }

  final iso7816 = Iso7816.from(tag);
  if (iso7816 != null) {
    return _bytesToHex(iso7816.identifier);
  }

  final iso15693 = Iso15693.from(tag);
  if (iso15693 != null) {
    return _bytesToHex(iso15693.identifier);
  }

  final felica = FeliCa.from(tag);
  if (felica != null) {
    return _bytesToHex(felica.currentIDm);
  }

  final nfcA = NfcA.from(tag);
  if (nfcA != null) {
    return _bytesToHex(nfcA.identifier);
  }

  final nfcB = NfcB.from(tag);
  if (nfcB != null) {
    return _bytesToHex(nfcB.identifier);
  }

  final nfcF = NfcF.from(tag);
  if (nfcF != null) {
    return _bytesToHex(nfcF.identifier);
  }

  final nfcV = NfcV.from(tag);
  if (nfcV != null) {
    return _bytesToHex(nfcV.identifier);
  }

  final isoDep = IsoDep.from(tag);
  if (isoDep != null) {
    return _bytesToHex(isoDep.identifier);
  }

  final mifareClassic = MifareClassic.from(tag);
  if (mifareClassic != null) {
    return _bytesToHex(mifareClassic.identifier);
  }

  final mifareUltralight = MifareUltralight.from(tag);
  if (mifareUltralight != null) {
    return _bytesToHex(mifareUltralight.identifier);
  }

  return null;
}

Future<List<NfcNdefRecordDto>> _extractNdefRecords(NfcTag tag) async {
  final ndef = Ndef.from(tag);
  if (ndef == null) {
    return const <NfcNdefRecordDto>[];
  }

  NdefMessage? message;
  try {
    message = ndef.cachedMessage ?? await ndef.read();
  } on Object {
    return const <NfcNdefRecordDto>[];
  }

  if (message.records.isEmpty) {
    return const <NfcNdefRecordDto>[];
  }

  return message.records.map(_recordToDto).toList(growable: false);
}

NfcNdefRecordDto _recordToDto(NdefRecord record) {
  return NfcNdefRecordDto(
    tnf: record.typeNameFormat.name,
    typeHex: _bytesToHex(record.type),
    identifierHex: _bytesToHex(record.identifier),
    payloadHex: _bytesToHex(record.payload),
    payloadText: _tryDecodeTextPayload(record.payload),
  );
}

void _addIfMissing(List<NfcTagTech> list, NfcTagTech value) {
  if (!list.contains(value)) {
    list.add(value);
  }
}

String _bytesToHex(Uint8List bytes) {
  final buffer = StringBuffer();
  for (final byte in bytes) {
    buffer.write(byte.toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}

String? _tryDecodeTextPayload(Uint8List payload) {
  if (payload.isEmpty) {
    return null;
  }

  try {
    final raw = payload.toList(growable: false);
    final status = raw.first;
    final languageCodeLength = status & 0x3F;
    final utf16 = (status & 0x80) != 0;

    final textBytes = raw.skip(languageCodeLength + 1).toList(growable: false);
    if (textBytes.isEmpty) {
      return null;
    }

    if (utf16) {
      if (textBytes.length.isOdd) {
        return null;
      }

      final codeUnits = <int>[];
      for (var index = 0; index < textBytes.length; index += 2) {
        codeUnits.add((textBytes[index] << 8) | textBytes[index + 1]);
      }
      return String.fromCharCodes(codeUnits);
    }

    return utf8.decode(textBytes, allowMalformed: true);
  } on Object {
    return null;
  }
}

Object? _normalizeRawValue(Object? value) {
  if (value is Uint8List) {
    return value.toList(growable: false);
  }
  if (value is Map<Object?, Object?>) {
    return value.map(
      (key, entryValue) => MapEntry(key is String ? key : key.toString(), _normalizeRawValue(entryValue)),
    );
  }
  if (value is Iterable<Object?>) {
    return value.map(_normalizeRawValue).toList(growable: false);
  }
  return value;
}
