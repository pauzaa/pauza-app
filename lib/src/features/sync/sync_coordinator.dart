import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:pauza/src/core/connectivity/domain/internet_health_gate.dart';
import 'package:pauza/src/features/auth/data/auth_repository.dart';
import 'package:pauza/src/features/modes/common/data/modes_repository.dart';
import 'package:pauza/src/features/profile/data/user_profile_repository.dart';
import 'package:pauza/src/features/restriction_lifecycle/data/restriction_lifecycle_repository.dart';
import 'package:pauza/src/features/streaks/data/streaks_repository.dart';
import 'package:pauza/src/features/sync/data/sync_local_data_source.dart';
import 'package:pauza/src/features/sync/data/sync_repository.dart';

final class SyncCoordinator with WidgetsBindingObserver {
  SyncCoordinator({
    required SyncRepository syncRepository,
    required SyncLocalDataSource syncLocalDataSource,
    required AuthRepository authRepository,
    required ModesRepository modesRepository,
    required UserProfileRepository userProfileRepository,
    required StreaksRepository streaksRepository,
    required RestrictionLifecycleRepository restrictionLifecycleRepository,
    required InternetHealthGate internetHealthGate,
  }) : _syncRepository = syncRepository,
       _syncLocalDataSource = syncLocalDataSource,
       _authRepository = authRepository,
       _modesRepository = modesRepository,
       _userProfileRepository = userProfileRepository,
       _streaksRepository = streaksRepository,
       _restrictionLifecycleRepository = restrictionLifecycleRepository,
       _internetHealthGate = internetHealthGate;

  final SyncRepository _syncRepository;
  final SyncLocalDataSource _syncLocalDataSource;
  final AuthRepository _authRepository;
  final ModesRepository _modesRepository;
  final UserProfileRepository _userProfileRepository;
  final StreaksRepository _streaksRepository;
  final RestrictionLifecycleRepository _restrictionLifecycleRepository;
  final InternetHealthGate _internetHealthGate;

  bool _isAttached = false;
  bool _initialDownloadCompleted = false;
  bool _pendingSyncRequested = false;
  StreamSubscription<void>? _sessionSubscription;
  Future<void>? _inFlightSync;

  void attach() {
    if (_isAttached) return;

    WidgetsBinding.instance.addObserver(this);
    _sessionSubscription = _authRepository.sessionStream.listen(_onSessionChanged);
    _internetHealthGate.addListener(_onConnectivityChanged);
    _isAttached = true;
  }

  void detach() {
    if (!_isAttached) return;

    WidgetsBinding.instance.removeObserver(this);
    _sessionSubscription?.cancel();
    _sessionSubscription = null;
    _internetHealthGate.removeListener(_onConnectivityChanged);
    _isAttached = false;
  }

  void requestSync() {
    if (!_authRepository.currentSession.isAuthenticated) return;
    if (!_initialDownloadCompleted) return;
    if (!_internetHealthGate.isHealthy) return;

    if (_inFlightSync != null) {
      _pendingSyncRequested = true;
      return;
    }

    unawaited(_runGuarded(() => _deduplicatedSync(_performSync)));
  }

  void _onConnectivityChanged() {
    if (_internetHealthGate.isHealthy) {
      requestSync();
    }
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

    unawaited(
      _runGuarded(() async {
        final hasCursors = await _syncLocalDataSource.hasAnySyncCursor();
        if (hasCursors) {
          await _deduplicatedSync(_performSync);
          _initialDownloadCompleted = true;
        } else {
          await _deduplicatedSync(_performInitialDownload);
        }
      }),
    );
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
      await _restrictionLifecycleRepository.syncFromPluginQueue();
    } on Object catch (e, s) {
      log('syncFromPluginQueue failed', name: 'pauza.sync', error: e, stackTrace: s);
    }

    try {
      final isPremium = _resolvePremiumStatus();
      await _modesRepository.reconcilePlugin(isPremium: isPremium);
    } on Object catch (e, s) {
      log('reconcilePlugin failed', name: 'pauza.sync', error: e, stackTrace: s);
    }

    try {
      _modesRepository.notifyExternalChange();
    } on Object catch (e, s) {
      log('notifyExternalChange failed', name: 'pauza.sync', error: e, stackTrace: s);
    }

    try {
      await _streaksRepository.refreshAggregates();
    } on Object catch (e, s) {
      log('refreshAggregates failed', name: 'pauza.sync', error: e, stackTrace: s);
    }
  }

  bool _resolvePremiumStatus() {
    return _userProfileRepository.cachedUser?.subscription?.isActive == true;
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
      if (_pendingSyncRequested) {
        _pendingSyncRequested = false;
        requestSync();
      }
    });
  }

  Future<void> _runGuarded(Future<void> Function() action) async {
    try {
      await action();
    } on Object catch (e, s) {
      log('sync failed', name: 'pauza.sync', error: e, stackTrace: s);
    }
  }
}
