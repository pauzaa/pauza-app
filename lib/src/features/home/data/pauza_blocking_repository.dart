import 'dart:async';

import 'package:pauza/src/core/common/disposable.dart';
import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:pauza/src/features/restriction_lifecycle/data/restriction_lifecycle_repository.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

abstract interface class BlockingRepository implements Disposable {
  Stream<RestrictionLifecycleAction> get lifecycleActions;

  Future<RestrictionState> getRestrictionSession();

  Future<void> startBlocking({required Mode mode, required ShieldConfiguration? shield});

  Future<void> stopBlocking();

  Future<void> pauseBlocking(Duration duration);

  Future<void> resumeBlocking();

  Future<void> syncRestrictionLifecycleEvents();
}

class PauzaBlockingRepository implements BlockingRepository {
  PauzaBlockingRepository({
    required AppRestrictionManager restrictions,
    required RestrictionLifecycleRepository restrictionLifecycleRepository,
  }) : _restrictions = restrictions,
       _restrictionLifecycleRepository = restrictionLifecycleRepository;

  final AppRestrictionManager _restrictions;
  final RestrictionLifecycleRepository _restrictionLifecycleRepository;
  final StreamController<RestrictionLifecycleAction> _lifecycleActionsController =
      StreamController<RestrictionLifecycleAction>.broadcast();

  @override
  Stream<RestrictionLifecycleAction> get lifecycleActions => _lifecycleActionsController.stream;

  @override
  Future<RestrictionState> getRestrictionSession() => _restrictions.getRestrictionSession();

  @override
  Future<void> startBlocking({required Mode mode, required ShieldConfiguration? shield}) async {
    await _restrictions.startSession(mode.toRestrictionMode());
    if (shield != null) {
      await _restrictions.configureShield(shield);
    }
    await syncRestrictionLifecycleEvents();
    _lifecycleActionsController.add(RestrictionLifecycleAction.start);
  }

  @override
  Future<void> stopBlocking() async {
    await _restrictions.endSession();
    await syncRestrictionLifecycleEvents();
    _lifecycleActionsController.add(RestrictionLifecycleAction.end);
  }

  @override
  Future<void> pauseBlocking(Duration duration) async {
    await _restrictions.pauseEnforcement(duration);
    await syncRestrictionLifecycleEvents();
    _lifecycleActionsController.add(RestrictionLifecycleAction.pause);
  }

  @override
  Future<void> resumeBlocking() async {
    await _restrictions.resumeEnforcement();
    await syncRestrictionLifecycleEvents();
    _lifecycleActionsController.add(RestrictionLifecycleAction.resume);
  }

  @override
  Future<void> syncRestrictionLifecycleEvents() async {
    try {
      await _restrictionLifecycleRepository.syncFromPluginQueue();
    } on Object {
      // Keep existing end-session behavior even if lifecycle sync fails.
    }
  }

  @override
  void dispose() {
    _lifecycleActionsController.close();
  }
}
