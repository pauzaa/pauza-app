import 'package:pauza/src/features/blocking/data/blocking_repository.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

class PauzaScreenTimeBlockingRepository implements BlockingRepository {
  PauzaScreenTimeBlockingRepository({AppRestrictionManager? restrictions})
    : _restrictions = restrictions ?? AppRestrictionManager();

  final AppRestrictionManager _restrictions;

  @override
  Future<List<String>> getRestrictedAppIds() =>
      _restrictions.getRestrictedApps();

  @override
  Future<void> startBlocking({
    required ShieldConfiguration shield,
    required List<String> appIds,
  }) async {
    await _restrictions.configureShield(shield);
    await _restrictions.restrictApps(appIds);
  }

  @override
  Future<void> stopBlocking() => _restrictions.clearAllRestrictions();
}
