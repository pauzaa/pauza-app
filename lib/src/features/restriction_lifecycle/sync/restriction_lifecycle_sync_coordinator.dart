import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:pauza/src/features/restriction_lifecycle/data/restriction_lifecycle_repository.dart';

final class RestrictionLifecycleSyncCoordinator with WidgetsBindingObserver {
  RestrictionLifecycleSyncCoordinator({
    required RestrictionLifecycleRepository repository,
  }) : _repository = repository;

  final RestrictionLifecycleRepository _repository;

  bool _isAttached = false;
  Future<void>? _inFlightSync;

  void attach() {
    if (_isAttached) {
      return;
    }

    WidgetsBinding.instance.addObserver(this);
    _isAttached = true;
  }

  void detach() {
    if (!_isAttached) {
      return;
    }

    WidgetsBinding.instance.removeObserver(this);
    _isAttached = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      return;
    }

    unawaited(syncNow().catchError((Object _) {}));
  }

  Future<void> syncNow({int batchSize = 200}) {
    final inFlight = _inFlightSync;
    if (inFlight != null) {
      return inFlight;
    }

    final syncFuture = _repository.syncFromPluginQueue(batchSize: batchSize);
    _inFlightSync = syncFuture;

    return syncFuture.whenComplete(() {
      if (identical(_inFlightSync, syncFuture)) {
        _inFlightSync = null;
      }
    });
  }
}
