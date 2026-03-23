import 'dart:async';

import 'package:pauza/src/core/common/disposable.dart';
import 'package:pauza/src/features/home/model/blocking_action_error.dart';
import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:pauza/src/features/restriction_lifecycle/data/restriction_lifecycle_repository.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

abstract interface class BlockingRepository implements Disposable {
  Stream<RestrictionLifecycleAction> get lifecycleActions;

  Future<RestrictionState> getRestrictionSession();

  Future<void> startBlocking({required Mode mode, required ShieldConfiguration? shield});

  Future<void> stopBlocking({
    required Mode? mode,
    required RestrictionState restrictionState,
    required RestrictionLifecycleReason reason,
    Duration? cooldownDuration,
  });

  Future<void> pauseBlocking(Duration duration, {required Mode? mode, required RestrictionState restrictionState});

  Future<void> resumeBlocking();

  Future<void> emergencyEndSession();

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
  Future<void> stopBlocking({
    required RestrictionState restrictionState,
    required Mode? mode,
    required RestrictionLifecycleReason reason,
    Duration? cooldownDuration,
  }) async {
    _validateBlockingAction(mode: mode, restrictionState: restrictionState, action: RestrictionLifecycleAction.end);
    await _restrictions.endSession(duration: cooldownDuration, reason: reason);
    await syncRestrictionLifecycleEvents();
    _lifecycleActionsController.add(RestrictionLifecycleAction.end);
  }

  @override
  Future<void> pauseBlocking(
    Duration duration, {
    required Mode? mode,
    required RestrictionState restrictionState,
  }) async {
    _validateBlockingAction(mode: mode, restrictionState: restrictionState, action: RestrictionLifecycleAction.pause);
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
  Future<void> emergencyEndSession() async {
    await _restrictions.endSession(reason: RestrictionLifecycleReason.emergency);
    await syncRestrictionLifecycleEvents();
    _lifecycleActionsController.add(RestrictionLifecycleAction.end);
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

  void _validateBlockingAction({
    required Mode? mode,
    required RestrictionState restrictionState,
    required RestrictionLifecycleAction action,
  }) {
    if (mode == null) {
      throw const ActiveModeUnavailableError();
    }

    switch (action) {
      case RestrictionLifecycleAction.start:
      case RestrictionLifecycleAction.resume:
        break;
      case RestrictionLifecycleAction.pause:
        _validatePauseLimit(mode: mode, restrictionState: restrictionState);
      case RestrictionLifecycleAction.end:
        _validateMinimumDuration(mode: mode, restrictionState: restrictionState);
    }
  }

  void _validatePauseLimit({required Mode mode, required RestrictionState restrictionState}) {
    final pauseCount = restrictionState.currentSessionEvents.where((event) {
      return event.action == RestrictionLifecycleAction.pause;
    }).length;

    if (pauseCount >= mode.allowedPausesCount) {
      throw const PauseLimitReachedError();
    }
  }

  void _validateMinimumDuration({required Mode mode, required RestrictionState restrictionState}) {
    final minimumDuration = mode.minimumDuration;
    if (minimumDuration == null) {
      return;
    }

    final startedAt = restrictionState.startedAt;
    if (startedAt == null) {
      return;
    }

    final elapsed = DateTime.now().toUtc().difference(startedAt.toUtc());
    if (elapsed >= minimumDuration) {
      return;
    }

    throw MinimumDurationNotReachedError(remaining: minimumDuration - elapsed);
  }
}
