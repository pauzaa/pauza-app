import 'package:pauza/src/features/home/data/app_fuse_active_mode_storage.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

abstract interface class BlockingRepository {
  Future<List<String>> getRestrictedAppIds();

  Future<void> startBlocking({
    required ShieldConfiguration shield,
    required List<String> appIds,
    required String modeId,
  });

  Future<void> stopBlocking();

  Future<String?> getActiveModeId();
}

class PauzaScreenTimeBlockingRepository implements BlockingRepository {
  PauzaScreenTimeBlockingRepository({
    required AppFuseActiveModeStorage activeModeStorage,
    AppRestrictionManager? restrictions,
  }) : _restrictions = restrictions ?? AppRestrictionManager(),
       _activeModeStorage = activeModeStorage;

  final AppRestrictionManager _restrictions;
  final AppFuseActiveModeStorage _activeModeStorage;

  @override
  Future<List<String>> getRestrictedAppIds() => _restrictions.getRestrictedApps();

  @override
  Future<void> startBlocking({
    required ShieldConfiguration shield,
    required List<String> appIds,
    required String modeId,
  }) async {
    await _restrictions.configureShield(shield);
    await _restrictions.restrictApps(appIds);
    await _activeModeStorage.writeActiveModeId(modeId);
  }

  @override
  Future<String?> getActiveModeId() => _activeModeStorage.readActiveModeId();

  @override
  Future<void> stopBlocking() async {
    await _restrictions.clearAllRestrictions();
    await _activeModeStorage.clearActiveModeId();
  }
}
