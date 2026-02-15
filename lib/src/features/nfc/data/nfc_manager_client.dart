import 'dart:async';
import 'dart:convert';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:nfc_manager/ndef_record.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:nfc_manager/nfc_manager_ios.dart';
import 'package:pauza/src/features/nfc/model/nfc_errors.dart';
import 'package:pauza/src/features/nfc/model/nfc_ndef_record_dto.dart';
import 'package:pauza/src/features/nfc/model/nfc_tag_tech.dart';

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

  static Future<NfcTagSnapshot> fromTag(NfcTag tag) async {
    final techTypes = _extractTechTypes(tag);
    final uidHex = _extractUidHex(tag);
    final ndefRecords = await _extractNdefRecords(tag);

    final rawSnapshot = <String, Object?>{
      'uidHex': uidHex,
      'techTypes': techTypes.map((tech) => tech.name).toList(growable: false),
      'platform': defaultTargetPlatform.name,
    };

    return NfcTagSnapshot(
      uidHex: uidHex,
      techTypes: techTypes.lock,
      isNdefFormatted: ndefRecords.isNotEmpty || _isNdefTag(tag),
      ndefRecords: ndefRecords.lock,
      rawSnapshot: rawSnapshot.lock,
    );
  }

  static List<NfcTagTech> _extractTechTypes(NfcTag tag) {
    final types = <NfcTagTech>[];

    if (NdefAndroid.from(tag) != null || NdefIos.from(tag) != null) {
      types.add(NfcTagTech.ndef);
    }

    final androidTag = NfcTagAndroid.from(tag);
    if (androidTag != null) {
      for (final tech in androidTag.techList) {
        final mapped = _mapAndroidTech(tech);
        if (mapped != NfcTagTech.unknown && !types.contains(mapped)) {
          types.add(mapped);
        }
      }
    }

    if (NfcAAndroid.from(tag) != null) {
      _addIfMissing(types, NfcTagTech.nfcA);
    }
    if (NfcBAndroid.from(tag) != null) {
      _addIfMissing(types, NfcTagTech.nfcB);
    }
    if (NfcFAndroid.from(tag) != null || FeliCaIos.from(tag) != null) {
      _addIfMissing(types, NfcTagTech.nfcF);
      _addIfMissing(types, NfcTagTech.felica);
    }
    if (NfcVAndroid.from(tag) != null || Iso15693Ios.from(tag) != null) {
      _addIfMissing(types, NfcTagTech.nfcV);
      _addIfMissing(types, NfcTagTech.iso15693);
    }
    if (IsoDepAndroid.from(tag) != null) {
      _addIfMissing(types, NfcTagTech.isoDep);
    }
    if (Iso7816Ios.from(tag) != null) {
      _addIfMissing(types, NfcTagTech.iso7816);
    }
    if (MifareClassicAndroid.from(tag) != null) {
      _addIfMissing(types, NfcTagTech.mifareClassic);
    }
    if (MifareUltralightAndroid.from(tag) != null) {
      _addIfMissing(types, NfcTagTech.mifareUltralight);
    }

    if (types.isEmpty) {
      types.add(NfcTagTech.unknown);
    }

    return types;
  }

  static NfcTagTech _mapAndroidTech(String tech) {
    final normalized = tech.toLowerCase();

    if (normalized.contains('nfca')) {
      return NfcTagTech.nfcA;
    }
    if (normalized.contains('nfcb')) {
      return NfcTagTech.nfcB;
    }
    if (normalized.contains('nfcf')) {
      return NfcTagTech.nfcF;
    }
    if (normalized.contains('nfcv')) {
      return NfcTagTech.nfcV;
    }
    if (normalized.contains('isodep')) {
      return NfcTagTech.isoDep;
    }
    if (normalized.contains('ndef')) {
      return NfcTagTech.ndef;
    }
    if (normalized.contains('mifareclassic')) {
      return NfcTagTech.mifareClassic;
    }
    if (normalized.contains('mifareultralight')) {
      return NfcTagTech.mifareUltralight;
    }

    return NfcTagTech.unknown;
  }

  static String? _extractUidHex(NfcTag tag) {
    final androidTag = NfcTagAndroid.from(tag);
    if (androidTag != null) {
      return _bytesToHex(androidTag.id);
    }

    final mifare = MiFareIos.from(tag);
    if (mifare != null) {
      return _bytesToHex(mifare.identifier);
    }

    final iso7816 = Iso7816Ios.from(tag);
    if (iso7816 != null) {
      return _bytesToHex(iso7816.identifier);
    }

    final iso15693 = Iso15693Ios.from(tag);
    if (iso15693 != null) {
      return _bytesToHex(iso15693.identifier);
    }

    return null;
  }

  static Future<List<NfcNdefRecordDto>> _extractNdefRecords(NfcTag tag) async {
    NdefMessage? message;

    final androidNdef = NdefAndroid.from(tag);
    if (androidNdef != null) {
      message =
          androidNdef.cachedNdefMessage ?? await androidNdef.getNdefMessage();
    }

    final iosNdef = NdefIos.from(tag);
    if (iosNdef != null) {
      message = iosNdef.cachedNdefMessage ?? await iosNdef.readNdef();
    }

    if (message == null) {
      return const <NfcNdefRecordDto>[];
    }

    return message.records
        .map((record) => _recordToDto(record))
        .toList(growable: false);
  }

  static bool _isNdefTag(NfcTag tag) {
    return NdefAndroid.from(tag) != null || NdefIos.from(tag) != null;
  }

  static NfcNdefRecordDto _recordToDto(NdefRecord record) {
    return NfcNdefRecordDto(
      tnf: record.typeNameFormat.name,
      typeHex: _bytesToHex(record.type),
      identifierHex: _bytesToHex(record.identifier),
      payloadHex: _bytesToHex(record.payload),
      payloadText: _tryDecodeTextPayload(record.payload),
    );
  }

  static void _addIfMissing(List<NfcTagTech> list, NfcTagTech value) {
    if (!list.contains(value)) {
      list.add(value);
    }
  }

  static String _bytesToHex(Uint8List bytes) {
    final buffer = StringBuffer();
    for (final byte in bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  static String? _tryDecodeTextPayload(Uint8List payload) {
    if (payload.isEmpty) {
      return null;
    }

    try {
      final raw = payload.toList(growable: false);
      final status = raw.first;
      final languageCodeLength = status & 0x3F;
      final utf16 = (status & 0x80) != 0;

      final textBytes = raw
          .skip(languageCodeLength + 1)
          .toList(growable: false);
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
}

abstract interface class NfcOperations {
  Future<NfcAvailability> checkAvailability();

  bool get isSessionActive;

  Future<NfcTagSnapshot> scanSingleTag({required Duration timeout});

  Future<void> stopSession({String? alertMessage, String? errorMessage});
}

class NfcManagerClient implements NfcOperations {
  NfcManagerClient._() : _manager = _tryGetDefaultManager();

  static final NfcManagerClient _instance = NfcManagerClient._();

  factory NfcManagerClient() => _instance;

  final NfcManager? _manager;

  bool _isSessionActive = false;

  @override
  bool get isSessionActive => _isSessionActive;

  @override
  Future<NfcAvailability> checkAvailability() async {
    final manager = _manager;
    if (manager == null) {
      return NfcAvailability.unsupported;
    }

    return manager.checkAvailability();
  }

  @override
  Future<NfcTagSnapshot> scanSingleTag({required Duration timeout}) async {
    final manager = _manager;
    if (manager == null) {
      throw const NfcException(
        code: NfcErrorCode.unsupported,
        message: 'NFC is not supported on this platform/device.',
      );
    }

    if (_isSessionActive) {
      throw const NfcException(
        code: NfcErrorCode.busy,
        message: 'Another NFC session is already active.',
      );
    }

    final completer = Completer<NfcTagSnapshot>();
    Timer? timer;
    _isSessionActive = true;

    try {
      await manager.startSession(
        pollingOptions: const <NfcPollingOption>{
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
          NfcPollingOption.iso18092,
        },
        onDiscovered: (tag) async {
          if (completer.isCompleted) {
            return;
          }

          try {
            final snapshot = await NfcTagSnapshot.fromTag(tag);
            completer.complete(snapshot);
          } on Object catch (error) {
            completer.completeError(error);
          }
        },
      );

      timer = Timer(timeout, () {
        if (completer.isCompleted) {
          return;
        }

        completer.completeError(
          const NfcException(
            code: NfcErrorCode.timeout,
            message: 'NFC scan timed out before a tag was discovered.',
          ),
        );
      });

      final snapshot = await completer.future;
      await stopSession();
      return snapshot;
    } finally {
      timer?.cancel();
      _isSessionActive = false;
    }
  }

  @override
  Future<void> stopSession({String? alertMessage, String? errorMessage}) async {
    final manager = _manager;
    if (manager == null) {
      return;
    }

    try {
      await manager.stopSession(
        alertMessageIos: alertMessage,
        errorMessageIos: errorMessage,
      );
    } on Object {
      // Ignore stop failures: session may already be closed or unavailable.
    }
  }

  static NfcManager? _tryGetDefaultManager() {
    try {
      return NfcManager.instance;
    } on Object {
      return null;
    }
  }
}
