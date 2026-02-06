import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:pauza/src/core/permissions/pauza_permission_requirement.dart';
import 'package:pauza/src/core/permissions/permission_gate_state.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart'
    show AndroidPermission, IOSPermission, PermissionManager, PermissionStatus;

abstract interface class PauzaPermissionGate implements Listenable {
  PermissionGateState get state;

  Stream<PermissionGateState> get stream;

  Future<void> refresh({bool force = false});

  Future<void> request(PauzaPermissionRequirement requirement);

  Future<void> openSettings(PauzaPermissionRequirement requirement);

  void dispose();
}

class PauzaPermissionGateNotifier extends ChangeNotifier
    with WidgetsBindingObserver
    implements PauzaPermissionGate {
  PauzaPermissionGateNotifier({
    required PermissionManager permissionManager,
    this.minRefreshInterval = const Duration(seconds: 1),
  }) : _permissionManager = permissionManager {
    WidgetsBinding.instance.addObserver(this);
  }

  static const MapEquality<PauzaPermissionRequirement, PermissionStatus>
  _statusEquality = MapEquality<PauzaPermissionRequirement, PermissionStatus>();

  final PermissionManager _permissionManager;
  final Duration minRefreshInterval;
  final StreamController<PermissionGateState> _controller =
      StreamController<PermissionGateState>.broadcast();

  PermissionGateState _state = PermissionGateState.initial();
  DateTime? _lastRefreshAt;
  Future<void>? _inFlightRefresh;

  @override
  PermissionGateState get state => _state;

  @override
  Stream<PermissionGateState> get stream => _controller.stream;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(refresh());
    }
  }

  @override
  Future<void> refresh({bool force = false}) async {
    final refreshInProgress = _inFlightRefresh;
    if (refreshInProgress != null) {
      return refreshInProgress;
    }

    if (!force &&
        _lastRefreshAt != null &&
        DateTime.now().difference(_lastRefreshAt!) < minRefreshInterval) {
      return;
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

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final androidPermission = requirement.androidPermission;
        if (androidPermission != null) {
          await _permissionManager.requestAndroidPermission(androidPermission);
        }
        break;
      case TargetPlatform.iOS:
        final iosPermission = requirement.iosPermission;
        if (iosPermission != null) {
          await _permissionManager.requestIOSPermission(iosPermission);
        }
        break;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        break;
    }

    await refresh(force: true);
  }

  @override
  Future<void> openSettings(PauzaPermissionRequirement requirement) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    final androidPermission = requirement.androidPermission;
    if (androidPermission == null) {
      return;
    }

    await _permissionManager.openAndroidPermissionSettings(androidPermission);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.close();
    super.dispose();
  }

  Future<void> _refreshInternal() async {
    final checkedAt = DateTime.now();
    try {
      final nextState = await _checkRequiredPermissions(checkedAt);
      _applyState(nextState);
    } on Object catch (error) {
      _applyState(
        PermissionGateState(
          statuses: _state.statuses,
          checkedAt: checkedAt,
          lastError: error,
        ),
      );
    } finally {
      _lastRefreshAt = checkedAt;
    }
  }

  Future<PermissionGateState> _checkRequiredPermissions(
    DateTime checkedAt,
  ) async {
    final required = PauzaPermissionRequirement.requiredForCurrentPlatform();
    if (required.isEmpty) {
      return PermissionGateState(checkedAt: checkedAt);
    }

    if (kIsWeb) {
      return PermissionGateState(checkedAt: checkedAt);
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final permissions = required
            .map((requirement) => requirement.androidPermission)
            .whereType<AndroidPermission>()
            .toList(growable: false);
        final statuses = await _permissionManager.checkAndroidPermissions(
          permissions,
        );
        final mapped = <PauzaPermissionRequirement, PermissionStatus>{
          for (final requirement in required)
            if (requirement.androidPermission case final permission)
              requirement:
                  statuses[permission] ?? PermissionStatus.notDetermined,
        };
        return PermissionGateState(statuses: mapped, checkedAt: checkedAt);
      case TargetPlatform.iOS:
        final permissions = required
            .map((requirement) => requirement.iosPermission)
            .whereType<IOSPermission>()
            .toList(growable: false);
        final statuses = await _permissionManager.checkIOSPermissions(
          permissions,
        );
        final mapped = <PauzaPermissionRequirement, PermissionStatus>{
          for (final requirement in required)
            if (requirement.iosPermission case final permission)
              requirement:
                  statuses[permission] ?? PermissionStatus.notDetermined,
        };
        return PermissionGateState(statuses: mapped, checkedAt: checkedAt);
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return PermissionGateState(checkedAt: checkedAt);
    }
  }

  void _applyState(PermissionGateState nextState) {
    final shouldNotify =
        !_statusEquality.equals(_state.statuses, nextState.statuses) ||
        _errorSignature(_state.lastError) !=
            _errorSignature(nextState.lastError);

    _state = nextState;
    if (!shouldNotify) {
      return;
    }

    if (!_controller.isClosed) {
      _controller.add(nextState);
    }
    notifyListeners();
  }

  String? _errorSignature(Object? error) =>
      error == null ? null : '${error.runtimeType}:${error.toString()}';
}
