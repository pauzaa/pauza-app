import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/features/modes/model/mode.dart';
import 'package:pauza/src/features/modes/model/mode_summary.dart';

abstract interface class ModesRepository {
  Future<List<ModeSummary>> listSummaries({required PauzaPlatform platform});

  Future<Mode?> getMode(String modeId);

  Future<List<String>> listBlockedAppIds(String modeId, PauzaPlatform platform);

  Future<void> deleteMode(String modeId);
}
