import 'dart:async';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pauza/src/features/auth/data/auth_repository.dart';
import 'package:pauza/src/features/devices/data/devices_repository.dart';

/// Coordinates FCM device token registration with the auth lifecycle.
///
/// Registers the FCM token on sign-in and on token refresh,
/// and unregisters it on sign-out.
final class DeviceTokenCoordinator {
  DeviceTokenCoordinator({
    required AuthRepository authRepository,
    required DevicesRepository devicesRepository,
  })  : _authRepository = authRepository,
        _devicesRepository = devicesRepository;

  final AuthRepository _authRepository;
  final DevicesRepository _devicesRepository;

  bool _isAttached = false;
  StreamSubscription<void>? _sessionSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;
  String? _lastRegisteredToken;

  void attach() {
    if (_isAttached) return;

    _sessionSubscription = _authRepository.sessionStream.listen(_onSessionChanged);
    _isAttached = true;
  }

  void detach() {
    if (!_isAttached) return;

    _sessionSubscription?.cancel();
    _sessionSubscription = null;
    _cancelTokenRefreshSubscription();
    _isAttached = false;
  }

  /// Unregisters the current FCM token from the server.
  ///
  /// Called during sign-out cleanup while the session is still valid.
  Future<void> unregisterCurrentToken() async {
    final token = _lastRegisteredToken;
    if (token == null) return;

    try {
      await _devicesRepository.unregister(fcmToken: token);
      log('DeviceTokenCoordinator: unregistered token', name: 'devices');
    } on Object catch (e) {
      log('DeviceTokenCoordinator: unregister failed: $e', name: 'devices');
    }
    _lastRegisteredToken = null;
  }

  // ---------------------------------------------------------------------------

  void _onSessionChanged(dynamic session) {
    final isAuthenticated = _authRepository.currentSession.isAuthenticated;

    if (isAuthenticated) {
      unawaited(_registerCurrentToken());
      _subscribeToTokenRefresh();
    } else {
      _cancelTokenRefreshSubscription();
      _lastRegisteredToken = null;
    }
  }

  Future<void> _registerCurrentToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;

      await _devicesRepository.register(fcmToken: token);
      _lastRegisteredToken = token;
      log('DeviceTokenCoordinator: registered token', name: 'devices');
    } on Object catch (e) {
      log('DeviceTokenCoordinator: register failed: $e', name: 'devices');
    }
  }

  void _subscribeToTokenRefresh() {
    _cancelTokenRefreshSubscription();
    _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh.listen(
      (newToken) => unawaited(_onTokenRefresh(newToken)),
    );
  }

  Future<void> _onTokenRefresh(String newToken) async {
    try {
      await _devicesRepository.register(fcmToken: newToken);
      _lastRegisteredToken = newToken;
      log('DeviceTokenCoordinator: re-registered after token refresh', name: 'devices');
    } on Object catch (e) {
      log('DeviceTokenCoordinator: token refresh register failed: $e', name: 'devices');
    }
  }

  void _cancelTokenRefreshSubscription() {
    _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
  }
}
