import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_util/nfc_util.dart';
import 'package:pauza/src/features/nfc/model/nfc_platform_types.dart';
import 'package:pauza/src/features/nfc/model/nfc_chip_identifier.dart';
import 'package:pauza/src/features/nfc/data/nfc_system_settings_launcher.dart';
import 'package:pauza/src/features/nfc/data/nfc_util_client.dart';
import 'package:pauza/src/features/nfc/model/nfc_errors.dart' hide NfcError;
import 'package:pauza/src/features/nfc/model/nfc_tag_tech.dart';

void main() {
  group('NfcUtilClient', () {
    late TargetPlatform? previousPlatformOverride;

    setUp(() {
      previousPlatformOverride = debugDefaultTargetPlatformOverride;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = previousPlatformOverride;
    });

    test('checkAvailability returns available when platform is available', () async {
      final client = NfcUtilClient(
        manager: _FakeNfcManagerGateway(),
        settingsLauncher: const NoopNfcSystemSettingsLauncher(),
      );

      final availability = await client.checkAvailability();

      expect(availability, NfcPlatformAvailability.available);
    });

    test('checkAvailability returns disabled when platform reports unavailable', () async {
      final client = NfcUtilClient(
        manager: _FakeNfcManagerGateway(isAvailableResult: false),
        settingsLauncher: const NoopNfcSystemSettingsLauncher(),
      );

      final availability = await client.checkAvailability();

      expect(availability, NfcPlatformAvailability.disabled);
    });

    test('scanSingleTag returns timeout when no tag is discovered', () async {
      final client = NfcUtilClient(
        manager: _FakeNfcManagerGateway(),
        settingsLauncher: const NoopNfcSystemSettingsLauncher(),
      );

      expect(client.scanSingleTag(timeout: const Duration(milliseconds: 10)), throwsA(isA<NfcTimeoutError>()));
    });

    test('scanSingleTag maps discovered nfc_util tag into snapshot', () async {
      final manager = _FakeNfcManagerGateway();
      final client = NfcUtilClient(manager: manager, settingsLauncher: const NoopNfcSystemSettingsLauncher());

      final pending = client.scanSingleTag(timeout: const Duration(seconds: 1));
      await Future<void>.delayed(const Duration(milliseconds: 1));
      await manager.triggerTag(_buildTag());

      final snapshot = await pending;

      expect(snapshot.uidHex, NfcChipIdentifier.parse('01020304'));
      expect(snapshot.isNdefFormatted, isTrue);
      expect(snapshot.techTypes, contains(NfcTagTech.ndef));
      expect(snapshot.techTypes, contains(NfcTagTech.nfcA));
      expect(snapshot.ndefRecords.length, 1);
      expect(snapshot.ndefRecords.first.payloadText, 'Hi');
    });

    test('scanSingleTag maps session user cancel to cancelled exception', () async {
      final manager = _FakeNfcManagerGateway();
      final client = NfcUtilClient(manager: manager, settingsLauncher: const NoopNfcSystemSettingsLauncher());

      final pending = client.scanSingleTag(timeout: const Duration(seconds: 1));
      await Future<void>.delayed(const Duration(milliseconds: 1));
      await manager.triggerError(const NfcError(type: NfcErrorType.userCanceled, message: 'cancelled'));

      await expectLater(pending, throwsA(isA<NfcCancelledError>()));
    });

    test('stopSession ignores platform stop errors', () async {
      final client = NfcUtilClient(
        manager: _FakeNfcManagerGateway(stopSessionError: StateError('session missing')),
        settingsLauncher: const NoopNfcSystemSettingsLauncher(),
      );

      await client.stopSession(alertMessage: 'Done', errorMessage: 'Ignored');
    });
  });
}

final class _FakeNfcManagerGateway implements NfcManagerGateway {
  _FakeNfcManagerGateway({this.isAvailableResult = true, this.stopSessionError});

  final bool isAvailableResult;
  final Object? stopSessionError;

  NfcTagCallback? _onDiscovered;
  NfcErrorCallback? _onError;

  @override
  Future<bool> isAvailable() async {
    return isAvailableResult;
  }

  @override
  Future<void> startSession({
    required NfcTagCallback onDiscovered,
    required NfcErrorCallback onError,
    required Set<NfcPollingOption> pollingOptions,
    required bool invalidateAfterFirstRead,
  }) async {
    _onDiscovered = onDiscovered;
    _onError = onError;
  }

  @override
  Future<void> stopSession({String? alertMessage, String? errorMessage}) async {
    if (stopSessionError case final error?) {
      throw error;
    }
  }

  Future<void> triggerTag(NfcTag tag) async {
    await _onDiscovered?.call(tag);
  }

  Future<void> triggerError(NfcError error) async {
    await _onError?.call(error);
  }
}

NfcTag _buildTag() {
  return NfcTag(
    handle: 'tag-1',
    data: <String, dynamic>{
      'nfca': <String, dynamic>{
        'identifier': Uint8List.fromList(const <int>[1, 2, 3, 4]),
        'atqa': Uint8List.fromList(const <int>[68, 0]),
        'maxTransceiveLength': 253,
        'sak': 0,
        'timeout': 100,
      },
      'ndef': <String, dynamic>{
        'identifier': Uint8List.fromList(const <int>[1, 2, 3, 4]),
        'isWritable': true,
        'maxSize': 256,
        'cachedMessage': <String, dynamic>{
          'records': <Map<String, dynamic>>[
            <String, dynamic>{
              'typeNameFormat': 1,
              'type': Uint8List.fromList(const <int>[0x54]),
              'identifier': Uint8List.fromList(const <int>[1]),
              'payload': Uint8List.fromList(const <int>[2, 101, 110, 72, 105]),
            },
          ],
        },
      },
    },
  );
}
