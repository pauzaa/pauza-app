import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/home/data/pauza_blocking_repository.dart';
import 'package:pauza/src/features/modes/common/model/mode_ending_pausing_scenario.dart';
import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:pauza/src/features/modes/common/model/mode_icon.dart';
import 'package:pauza/src/features/restriction_lifecycle/data/restriction_lifecycle_repository.dart';
import 'package:pauza/src/features/restriction_lifecycle/model/restriction_lifecycle_event_log.dart';
import 'package:pauza/src/features/restriction_lifecycle/model/restriction_session_log.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

void main() {
  group('PauzaBlockingRepository', () {
    test('emits lifecycle actions for start, pause, resume, and stop', () async {
      final restrictions = _FakeAppRestrictionManager();
      final lifecycleRepository = _FakeRestrictionLifecycleRepository();
      final repository = PauzaBlockingRepository(
        restrictions: restrictions,
        restrictionLifecycleRepository: lifecycleRepository,
      );
      final emittedActions = <RestrictionLifecycleAction>[];
      final subscription = repository.lifecycleActions.listen(emittedActions.add);

      await repository.startBlocking(mode: _mode, shield: null);
      await repository.pauseBlocking(const Duration(minutes: 1));
      await repository.resumeBlocking();
      await repository.stopBlocking();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(emittedActions, <RestrictionLifecycleAction>[
        RestrictionLifecycleAction.start,
        RestrictionLifecycleAction.pause,
        RestrictionLifecycleAction.resume,
        RestrictionLifecycleAction.end,
      ]);

      await subscription.cancel();
      repository.dispose();
    });

    test('does not emit lifecycle action when only sync is called', () async {
      final restrictions = _FakeAppRestrictionManager();
      final lifecycleRepository = _FakeRestrictionLifecycleRepository();
      final repository = PauzaBlockingRepository(
        restrictions: restrictions,
        restrictionLifecycleRepository: lifecycleRepository,
      );
      final emittedActions = <RestrictionLifecycleAction>[];
      final subscription = repository.lifecycleActions.listen(emittedActions.add);

      await repository.syncRestrictionLifecycleEvents();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(emittedActions, isEmpty);

      await subscription.cancel();
      repository.dispose();
    });

    test('closes lifecycle stream on dispose', () async {
      final restrictions = _FakeAppRestrictionManager();
      final lifecycleRepository = _FakeRestrictionLifecycleRepository();
      final repository = PauzaBlockingRepository(
        restrictions: restrictions,
        restrictionLifecycleRepository: lifecycleRepository,
      );
      final done = Completer<void>();
      final subscription = repository.lifecycleActions.listen((_) {}, onDone: done.complete);

      repository.dispose();
      await done.future;

      await subscription.cancel();
    });
  });
}

final Mode _mode = Mode(
  id: 'mode-1',
  title: 'Mode',
  textOnScreen: 'Focus',
  description: null,
  allowedPausesCount: 1,
  minimumDuration: null,
  endingPausingScenario: ModeEndingPausingScenario.manual,
  icon: ModeIconCatalog.defaultIcon,
  schedule: null,
  blockedAppIds: const ISet<AppIdentifier>.empty(),
  createdAt: DateTime(2026, 2, 20).toUtc(),
  updatedAt: DateTime(2026, 2, 20).toUtc(),
);

class _FakeAppRestrictionManager extends AppRestrictionManager {
  @override
  Future<void> startSession(RestrictionMode mode, {Duration? duration}) async {}

  @override
  Future<void> endSession({Duration? duration}) async {}

  @override
  Future<void> pauseEnforcement(Duration duration) async {}

  @override
  Future<void> resumeEnforcement() async {}

  @override
  Future<void> configureShield(ShieldConfiguration configuration) async {}
}

class _FakeRestrictionLifecycleRepository implements RestrictionLifecycleRepository {
  @override
  Future<List<RestrictionLifecycleEventLog>> getEvents({String? modeId, String? sessionId, int limit = 500}) async {
    return const <RestrictionLifecycleEventLog>[];
  }

  @override
  Future<List<RestrictionSessionLog>> getSessions({String? modeId, int limit = 200}) async {
    return const <RestrictionSessionLog>[];
  }

  @override
  Future<void> syncFromPluginQueue({int batchSize = 200}) async {}
}
