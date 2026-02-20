import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:pauza/src/features/restriction_lifecycle/data/restriction_lifecycle_repository.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

abstract interface class BlockingRepository {
  Future<RestrictionState> getRestrictionSession();

  Future<void> startBlocking({
    required Mode mode,
    required ShieldConfiguration? shield,
  });

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

  @override
  Future<RestrictionState> getRestrictionSession() =>
      _restrictions.getRestrictionSession();

  @override
  Future<void> startBlocking({
    required Mode mode,
    required ShieldConfiguration? shield,
  }) async {
    await _restrictions.startSession(mode.toRestrictionMode());
    if (shield != null) {
      await _restrictions.configureShield(shield);
    }
    await syncRestrictionLifecycleEvents();
  }

  @override
  Future<void> stopBlocking() async {
    await _restrictions.endSession();
    await syncRestrictionLifecycleEvents();
  }

  @override
  Future<void> pauseBlocking(Duration duration) async {
    await _restrictions.pauseEnforcement(duration);
    await syncRestrictionLifecycleEvents();
  }

  @override
  Future<void> resumeBlocking() async {
    await _restrictions.resumeEnforcement();
    await syncRestrictionLifecycleEvents();
  }

  @override
  Future<void> syncRestrictionLifecycleEvents() async {
    try {
      await _restrictionLifecycleRepository.syncFromPluginQueue();
    } on Object {
      // Keep existing end-session behavior even if lifecycle sync fails.
    }
  }
}
