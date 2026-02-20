import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:pauza/src/features/permissions/model/pauza_permission_requirement.dart';
import 'package:pauza/src/features/permissions/model/permission_gate_state.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart'
    show AndroidPermission, IOSPermission, PermissionManager, PermissionStatus;

abstract interface class PauzaPermissionGate implements Listenable {
  PermissionGateState get state;

  Future<void> refresh({bool force = false});

  Future<void> request(PauzaPermissionRequirement requirement);

  Future<void> openSettings(PauzaPermissionRequirement requirement);

  void dispose();
}

class PauzaPermissionGateNotifier extends ChangeNotifier with WidgetsBindingObserver implements PauzaPermissionGate {
  PauzaPermissionGateNotifier({
    required PermissionManager permissionManager,
    this.minRefreshInterval = const Duration(seconds: 1),
  }) : _permissionManager = permissionManager {
    WidgetsBinding.instance.addObserver(this);
  }

  final PermissionManager _permissionManager;
  final Duration minRefreshInterval;

  static const MapEquality<PauzaPermissionRequirement, PermissionStatus> _statusEquality =
      MapEquality<PauzaPermissionRequirement, PermissionStatus>();

  PermissionGateState _state = PermissionGateState.initial();

  DateTime? _lastRefreshAt;
  Future<void>? _inFlightRefresh;

  @override
  PermissionGateState get state => _state;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(refresh());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> refresh({bool force = false}) async {
    final refreshInProgress = _inFlightRefresh;
    if (refreshInProgress != null) {
      return refreshInProgress;
    }

    if (!force) {
      if (_lastRefreshAt case final lastRefreshAt? when DateTime.now().difference(lastRefreshAt) < minRefreshInterval) {
        return;
      }
    }

    final refreshFuture = _refreshInternal();

    _inFlightRefresh = refreshFuture;

    try {
      await refreshFuture;
    } finally {
      if (identical(_inFlightRefresh, refreshFuture)) {
        _inFlightRefresh = null;
      }
    }
  }

  @override
  Future<void> request(PauzaPermissionRequirement requirement) async {
    if (kIsWeb) {
      return;
    }

    if (Platform.isAndroid) {
      final androidPermission = requirement.androidPermission;
      if (androidPermission != null) {
        await _permissionManager.requestAndroidPermission(androidPermission);
      }
    }

    if (Platform.isIOS) {
      final iosPermission = requirement.iosPermission;
      if (iosPermission != null) {
        await _permissionManager.requestIOSPermission(iosPermission);
      }
    }

    await refresh(force: true);
  }

  @override
  Future<void> openSettings(PauzaPermissionRequirement requirement) async {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }

    final androidPermission = requirement.androidPermission;
    if (androidPermission == null) {
      return;
    }

    await _permissionManager.openAndroidPermissionSettings(androidPermission);
  }

  Future<void> _refreshInternal() async {
    final checkedAt = DateTime.now();
    try {
      final nextState = await _checkRequiredPermissions(checkedAt);
      _applyState(nextState);
    } on Object catch (error) {
      _applyState(PermissionGateState(statuses: _state.statuses, checkedAt: checkedAt, lastError: error));
    } finally {
      _lastRefreshAt = checkedAt;
    }
  }

  Future<PermissionGateState> _checkRequiredPermissions(DateTime checkedAt) async {
    final required = PauzaPermissionRequirement.requiredForCurrentPlatform;
    if (required.isEmpty) {
      return PermissionGateState(checkedAt: checkedAt);
    }

    if (kIsWeb) {
      return PermissionGateState(checkedAt: checkedAt);
    }

    if (Platform.isAndroid) {
      final permissions = required
          .map((requirement) => requirement.androidPermission)
          .whereType<AndroidPermission>()
          .toList(growable: false);
      final statuses = await _permissionManager.checkAndroidPermissions(permissions);
      final mapped = <PauzaPermissionRequirement, PermissionStatus>{
        for (final requirement in required)
          if (requirement.androidPermission case final permission)
            requirement: statuses[permission] ?? PermissionStatus.notDetermined,
      };
      return PermissionGateState(statuses: mapped, checkedAt: checkedAt);
    }

    if (Platform.isIOS) {
      final permissions = required
          .map((requirement) => requirement.iosPermission)
          .whereType<IOSPermission>()
          .toList(growable: false);
      final statuses = await _permissionManager.checkIOSPermissions(permissions);
      final mapped = <PauzaPermissionRequirement, PermissionStatus>{
        for (final requirement in required)
          if (requirement.iosPermission case final permission)
            requirement: statuses[permission] ?? PermissionStatus.notDetermined,
      };
      return PermissionGateState(statuses: mapped, checkedAt: checkedAt);
    }

    return PermissionGateState(checkedAt: checkedAt);
  }

  void _applyState(PermissionGateState nextState) {
    final shouldNotify =
        !_statusEquality.equals(_state.statuses, nextState.statuses) ||
        _errorSignature(_state.lastError) != _errorSignature(nextState.lastError);

    _state = nextState;
    if (!shouldNotify) {
      return;
    }

    notifyListeners();
  }

  String? _errorSignature(Object? error) => error == null ? null : '${error.runtimeType}:${error.toString()}';
}
