import 'dart:async';
import 'dart:developer';

import 'package:pauza/src/features/restriction_lifecycle/data/restriction_lifecycle_repository.dart';

final class RestrictionLifecycleSyncCoordinator {
  RestrictionLifecycleSyncCoordinator({required RestrictionLifecycleRepository repository}) : _repository = repository;

  final RestrictionLifecycleRepository _repository;

  Future<void>? _inFlightSync;

  Future<void> syncNow({int batchSize = 200}) {
    final inFlight = _inFlightSync;
    if (inFlight != null) {
      return inFlight;
    }

    final syncFuture = _sync(batchSize: batchSize);
    _inFlightSync = syncFuture;

    return syncFuture.whenComplete(() {
      if (identical(_inFlightSync, syncFuture)) {
        _inFlightSync = null;
      }
    });
  }

  Future<void> _sync({required int batchSize}) async {
    try {
      await _repository.syncFromPluginQueue(batchSize: batchSize);
    } on Object catch (e, s) {
      log('syncFromPluginQueue failed', name: 'pauza.sync', error: e, stackTrace: s);
    }
  }
}
