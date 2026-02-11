import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

abstract interface class BlockingRepository {
  Future<RestrictionSession> getRestrictionSession();

  Future<void> startBlocking({required Mode mode, required ShieldConfiguration? shield});

  Future<void> stopBlocking();
}

class PauzaScreenTimeBlockingRepository implements BlockingRepository {
  PauzaScreenTimeBlockingRepository({required AppRestrictionManager restrictions})
    : _restrictions = restrictions;

  final AppRestrictionManager _restrictions;

  @override
  Future<RestrictionSession> getRestrictionSession() => _restrictions.getRestrictionSession();

  @override
  Future<void> startBlocking({required Mode mode, required ShieldConfiguration? shield}) async {
    await _restrictions.startSession(mode.toRestrictionMode());
    if (shield != null) {
      await _restrictions.configureShield(shield);
    }
  }

  @override
  Future<void> stopBlocking() async {
    await _restrictions.endSession();
  }
}
