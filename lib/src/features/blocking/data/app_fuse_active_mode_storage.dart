import 'package:appfuse/appfuse.dart';
import 'package:pauza/src/core/common/pauza_constants.dart';
import 'package:pauza/src/features/blocking/data/active_mode_storage.dart';

class AppFuseActiveModeStorage implements ActiveModeStorage {
  const AppFuseActiveModeStorage({required AppFuseController fuseController})
    : _fuseController = fuseController;

  final AppFuseController _fuseController;

  @override
  Future<String?> readActiveModeId() async {
    return _fuseController.state.getCustomSetting<String>(
      PauzaConstants.blockingActiveModeKey,
    );
  }

  @override
  Future<void> writeActiveModeId(String modeId) {
    return _fuseController.setCustomSetting<String>(
      PauzaConstants.blockingActiveModeKey,
      modeId,
    );
  }

  @override
  Future<void> clearActiveModeId() {
    return _fuseController.setCustomSetting<Object?>(
      PauzaConstants.blockingActiveModeKey,
      null,
    );
  }
}
