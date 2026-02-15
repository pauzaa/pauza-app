import 'dart:async';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart';

typedef IntentLaunch = Future<void> Function();

abstract interface class NfcSystemSettingsLauncher {
  bool get isSupported;

  Future<bool> openNfcSettings();
}

final class AndroidIntentNfcSystemSettingsLauncher implements NfcSystemSettingsLauncher {
  AndroidIntentNfcSystemSettingsLauncher({
    @visibleForTesting bool? isAndroidPlatform,
    @visibleForTesting IntentLaunch? openNfcSettingsIntent,
    @visibleForTesting IntentLaunch? openWirelessSettingsIntent,
  }) : _isAndroidPlatform = (!kIsWeb && Platform.isAndroid),
       _openNfcSettingsIntent = openNfcSettingsIntent ?? _defaultOpenNfcSettingsIntent,
       _openWirelessSettingsIntent =
           openWirelessSettingsIntent ?? _defaultOpenWirelessSettingsIntent;

  final bool _isAndroidPlatform;
  final IntentLaunch _openNfcSettingsIntent;
  final IntentLaunch _openWirelessSettingsIntent;

  @override
  bool get isSupported => _isAndroidPlatform;

  @override
  Future<bool> openNfcSettings() async {
    if (!isSupported) {
      return false;
    }

    try {
      await _openNfcSettingsIntent();
      return true;
    } on Object {
      try {
        await _openWirelessSettingsIntent();
        return true;
      } on Object {
        return false;
      }
    }
  }

  static Future<void> _defaultOpenNfcSettingsIntent() async {
    const intent = AndroidIntent(action: 'android.settings.NFC_SETTINGS');
    await intent.launch();
  }

  static Future<void> _defaultOpenWirelessSettingsIntent() async {
    const intent = AndroidIntent(action: 'android.settings.WIRELESS_SETTINGS');
    await intent.launch();
  }
}

final class NoopNfcSystemSettingsLauncher implements NfcSystemSettingsLauncher {
  const NoopNfcSystemSettingsLauncher();

  @override
  bool get isSupported => false;

  @override
  Future<bool> openNfcSettings() async => false;
}
