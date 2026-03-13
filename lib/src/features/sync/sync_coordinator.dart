import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:pauza/src/features/auth/data/auth_repository.dart';
import 'package:pauza/src/features/modes/common/data/modes_repository.dart';
import 'package:pauza/src/features/streaks/data/streaks_repository.dart';
import 'package:pauza/src/features/sync/data/sync_local_data_source.dart';
import 'package:pauza/src/features/sync/data/sync_repository.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart' show AppRestrictionManager;

final class SyncCoordinator with WidgetsBindingObserver {
  SyncCoordinator({
    required SyncRepository syncRepository,
    required SyncLocalDataSource syncLocalDataSource,
    required AuthRepository authRepository,
    required ModesRepository modesRepository,
    required StreaksRepository streaksRepository,
    required AppRestrictionManager restrictions,
  })  : _syncRepository = syncRepository,
        _syncLocalDataSource = syncLocalDataSource,
        _authRepository = authRepository,
        _modesRepository = modesRepository,
        _streaksRepository = streaksRepository,
        _restrictions = restrictions;

  final SyncRepository _syncRepository;
  final SyncLocalDataSource _syncLocalDataSource;
  final AuthRepository _authRepository;
  final ModesRepository _modesRepository;
  final StreaksRepository _streaksRepository;
  final AppRestrictionManager _restrictions;

  bool _isAttached = false;
  bool _initialDownloadCompleted = false;
  StreamSubscription<void>? _sessionSubscription;
  Future<void>? _inFlightSync;

  void attach() {
    if (_isAttached) return;

    WidgetsBinding.instance.addObserver(this);
    _sessionSubscription = _authRepository.sessionStream.listen(_onSessionChanged);
    _isAttached = true;
  }

  void detach() {
    if (!_isAttached) return;

    WidgetsBinding.instance.removeObserver(this);
    _sessionSubscription?.cancel();
    _sessionSubscription = null;
    _isAttached = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (!_authRepository.currentSession.isAuthenticated) return;
    if (!_initialDownloadCompleted) return;

    unawaited(_runGuarded(() => _deduplicatedSync(_performSync)));
  }

  void _onSessionChanged(dynamic session) {
    if (!_authRepository.currentSession.isAuthenticated) return;

    unawaited(_runGuarded(() async {
      final hasCursors = await _syncLocalDataSource.hasAnySyncCursor();
      if (hasCursors) {
        await _deduplicatedSync(_performSync);
      } else {
        await _deduplicatedSync(_performInitialDownload);
      }
    }));
  }

  Future<void> _performSync() async {
    await _syncRepository.sync();
    await _postSync();
  }

  Future<void> _performInitialDownload() async {
    await _syncRepository.initialDownload();
    _initialDownloadCompleted = true;
    await _postSync();
  }

  Future<void> _postSync() async {
    try {
      await _reconcilePluginModes();
    } on Object {
      // Best-effort plugin reconciliation.
    }

    try {
      _modesRepository.notifyExternalChange();
    } on Object {
      // Best-effort UI notification.
    }

    try {
      await _streaksRepository.refreshAggregates();
    } on Object {
      // Best-effort streak refresh.
    }
  }

  Future<void> _reconcilePluginModes() async {
    final config = await _restrictions.getModesConfig();
    final pluginModeIds = config.modes.map((m) => m.modeId).toSet();
    final dbModes = await _modesRepository.getModes();
    final dbModeIds = dbModes.map((m) => m.id).toSet();

    final staleIds = pluginModeIds.difference(dbModeIds);
    for (final id in staleIds) {
      try {
        await _restrictions.removeMode(id);
      } on Object {
        // Best-effort removal.
      }
    }

    for (final mode in dbModes) {
      try {
        await _restrictions.upsertMode(mode.toRestrictionMode());
      } on Object {
        // Best-effort upsert.
      }
    }
  }

  Future<void> _deduplicatedSync(Future<void> Function() action) {
    final inFlight = _inFlightSync;
    if (inFlight != null) return inFlight;

    final syncFuture = action();
    _inFlightSync = syncFuture;

    return syncFuture.whenComplete(() {
      if (identical(_inFlightSync, syncFuture)) {
        _inFlightSync = null;
      }
    });
  }

  Future<void> _runGuarded(Future<void> Function() action) async {
    try {
      await action();
    } on Object {
      // Silent failure — retries on next resume or session change.
    }
  }
}
