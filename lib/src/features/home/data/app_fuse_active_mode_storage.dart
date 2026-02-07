import 'package:appfuse/appfuse.dart';

abstract interface class ActiveModeStorage {
  static const String blockingActiveModeKey = 'pauza.blocking.active_mode_id';
  static const String iosShieldAppGroupId = 'group.com.menace.pauza';

  Future<String?> readActiveModeId();

  Future<void> writeActiveModeId(String modeId);

  Future<void> clearActiveModeId();
}

final class AppFuseActiveModeStorage implements ActiveModeStorage {
  const AppFuseActiveModeStorage({required AppFuseController fuseController})
    : _fuseController = fuseController;

  final AppFuseController _fuseController;

  @override
  Future<String?> readActiveModeId() async {
    return _fuseController.state.getCustomSetting<String>(ActiveModeStorage.blockingActiveModeKey);
  }

  @override
  Future<void> writeActiveModeId(String modeId) {
    return _fuseController.setCustomSetting<String>(
      ActiveModeStorage.blockingActiveModeKey,
      modeId,
    );
  }

  @override
  Future<void> clearActiveModeId() {
    return _fuseController.setCustomSetting<Object?>(ActiveModeStorage.blockingActiveModeKey, null);
  }
}
