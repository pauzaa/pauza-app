import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nfc_util/nfc_util.dart';
import 'package:pauza/src/features/nfc/model/nfc_platform_types.dart';
import 'package:pauza/src/features/nfc/data/nfc_system_settings_launcher.dart';
import 'package:pauza/src/features/nfc/model/nfc_errors.dart';

abstract interface class NfcOperations {
  Future<NfcPlatformAvailability> checkAvailability();

  bool get isSessionActive;

  bool get canOpenSystemSettingsForNfc;

  Future<bool> openSystemSettingsForNfc();

  Future<NfcTagSnapshot> scanSingleTag({required Duration timeout});

  Future<void> stopSession({String? alertMessage, String? errorMessage});
}

class NfcUtilClient implements NfcOperations {
  NfcUtilClient._({required NfcManagerGateway manager, required NfcSystemSettingsLauncher settingsLauncher})
    : _manager = manager,
      _settingsLauncher = settingsLauncher;

  factory NfcUtilClient({NfcManagerGateway? manager, NfcSystemSettingsLauncher? settingsLauncher}) {
    return NfcUtilClient._(
      manager: manager ?? _DefaultNfcManagerGateway(),
      settingsLauncher: settingsLauncher ?? AndroidIntentNfcSystemSettingsLauncher(),
    );
  }

  final NfcManagerGateway _manager;
  final NfcSystemSettingsLauncher _settingsLauncher;

  bool _isSessionActive = false;

  @override
  bool get isSessionActive => _isSessionActive;

  @override
  bool get canOpenSystemSettingsForNfc => _settingsLauncher.isSupported;

  @override
  Future<bool> openSystemSettingsForNfc() async {
    if (!canOpenSystemSettingsForNfc) {
      return false;
    }

    return _settingsLauncher.openNfcSettings();
  }

  @override
  Future<NfcPlatformAvailability> checkAvailability() async {
    if (kIsWeb) {
      return NfcPlatformAvailability.notSupported;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        break;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return NfcPlatformAvailability.notSupported;
    }

    try {
      final isAvailable = await _manager.isAvailable();
      if (isAvailable) {
        return NfcPlatformAvailability.available;
      }

      return NfcPlatformAvailability.disabled;
    } on Object {
      return NfcPlatformAvailability.unknown;
    }
  }

  @override
  Future<NfcTagSnapshot> scanSingleTag({required Duration timeout}) async {
    if (_isSessionActive) {
      throw const NfcException(code: NfcErrorCode.busy, message: 'Another NFC session is already active.');
    }

    final completer = Completer<NfcTagSnapshot>();
    Timer? timer;
    _isSessionActive = true;

    try {
      await _manager.startSession(
        onDiscovered: (tag) async {
          if (completer.isCompleted) {
            return;
          }

          try {
            final snapshot = await NfcTagSnapshot.mapNfcTagSnapshotFromUtilTag(tag);
            completer.complete(snapshot);
          } on Object catch (error) {
            completer.completeError(error);
          }
        },
        onError: (error) async {
          if (completer.isCompleted) {
            return;
          }

          completer.completeError(NfcException.fromNfcError(error));
        },
        pollingOptions: const <NfcPollingOption>{NfcPollingOption.iso14443, NfcPollingOption.iso15693, NfcPollingOption.iso18092},
        invalidateAfterFirstRead: true,
      );

      timer = Timer(timeout, () {
        if (completer.isCompleted) {
          return;
        }

        completer.completeError(const NfcException(code: NfcErrorCode.timeout, message: 'NFC scan timed out before a tag was discovered.'));
      });

      return await completer.future;
    } on Object catch (error) {
      throw _mapUnhandledError(error);
    } finally {
      timer?.cancel();
      _isSessionActive = false;
      await _safeStopSession();
    }
  }

  @override
  Future<void> stopSession({String? alertMessage, String? errorMessage}) async {
    await _stopSessionCore(alertMessage: alertMessage, errorMessage: errorMessage);
  }

  Future<void> _safeStopSession() async {
    await _stopSessionCore();
  }

  Future<void> _stopSessionCore({String? alertMessage, String? errorMessage}) async {
    try {
      await _manager.stopSession(alertMessage: alertMessage, errorMessage: errorMessage);
    } on Object {
      // Ignore stop failures: session may already be closed or unavailable.
    }
  }

  NfcException _mapUnhandledError(Object error) {
    if (error is NfcException) {
      return error;
    }

    final message = error.toString().toLowerCase();

    if (message.contains('busy') || message.contains('already')) {
      return const NfcException(code: NfcErrorCode.busy, message: 'Another NFC session is already active.');
    }
    if (message.contains('permission') || message.contains('denied') || message.contains('unauthorized')) {
      return const NfcException(code: NfcErrorCode.permissionDenied, message: 'NFC permission was denied.');
    }
    if (message.contains('cancel')) {
      return const NfcException(code: NfcErrorCode.cancelled, message: 'NFC scan session was cancelled.');
    }
    if (message.contains('timeout')) {
      return const NfcException(code: NfcErrorCode.timeout, message: 'NFC scan timed out before a tag was discovered.');
    }
    if (message.contains('unsupported') || message.contains('not available') || message.contains('unavailable')) {
      return const NfcException(code: NfcErrorCode.unsupported, message: 'NFC is not supported on this platform/device.');
    }

    return NfcException(code: NfcErrorCode.unknown, message: 'Unexpected NFC error.', cause: error);
  }
}

abstract interface class NfcManagerGateway {
  Future<bool> isAvailable();

  Future<void> startSession({
    required NfcTagCallback onDiscovered,
    required NfcErrorCallback onError,
    required Set<NfcPollingOption> pollingOptions,
    required bool invalidateAfterFirstRead,
  });

  Future<void> stopSession({String? alertMessage, String? errorMessage});
}

final class _DefaultNfcManagerGateway implements NfcManagerGateway {
  final NfcManager _manager = NfcManager.instance;

  @override
  Future<bool> isAvailable() async {
    return _manager.isAvailable();
  }

  @override
  Future<void> startSession({
    required NfcTagCallback onDiscovered,
    required NfcErrorCallback onError,
    required Set<NfcPollingOption> pollingOptions,
    required bool invalidateAfterFirstRead,
  }) async {
    await _manager.startSession(
      onDiscovered: onDiscovered,
      onError: onError,
      pollingOptions: pollingOptions,
      invalidateAfterFirstRead: invalidateAfterFirstRead,
    );
  }

  @override
  Future<void> stopSession({String? alertMessage, String? errorMessage}) async {
    await _manager.stopSession(alertMessage: alertMessage, errorMessage: errorMessage);
  }
}
