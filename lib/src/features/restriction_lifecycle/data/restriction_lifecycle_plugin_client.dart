import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

abstract interface class RestrictionLifecyclePluginClient {
  Future<IList<RestrictionLifecycleEvent>> getPendingLifecycleEvents({int limit = 200});

  Future<void> ackLifecycleEvents({required String throughEventId});
}

final class RestrictionLifecyclePluginClientImpl implements RestrictionLifecyclePluginClient {
  const RestrictionLifecyclePluginClientImpl({required AppRestrictionManager restrictions}) : _restrictions = restrictions;

  final AppRestrictionManager _restrictions;

  @override
  Future<IList<RestrictionLifecycleEvent>> getPendingLifecycleEvents({int limit = 200}) async {
    return (await _restrictions.getPendingLifecycleEvents(limit: limit)).toIList();
  }

  @override
  Future<void> ackLifecycleEvents({required String throughEventId}) {
    return _restrictions.ackLifecycleEvents(throughEventId: throughEventId);
  }
}
