import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/features/home/bloc/home_stats_bloc.dart';
import 'package:pauza/src/features/streaks/common/model/streak_snapshot.dart';
import 'package:pauza/src/features/streaks/common/model/streak_types.dart';
import 'package:pauza/src/features/streaks/data/streaks_repository.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

void main() {
  group('HomeStatsBloc', () {
    test('loads snapshot on initialization and maps values', () async {
      final repository = _FakeStreaksRepository(
        responses: <Object>[_snapshot(streakDays: 3, focusedDuration: const Duration(minutes: 27))],
      );
      final lifecycleActionsController = StreamController<RestrictionLifecycleAction>.broadcast();
      final bloc = HomeStatsBloc(
        streaksRepository: repository,
        lifecycleActions: lifecycleActionsController.stream,
        nowLocal: () => _asOfLocal,
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(repository.getGlobalSnapshotCallCount, 1);
      expect(bloc.state.streakDays, 3);
      expect(bloc.state.focusedDuration, const Duration(minutes: 27));

      await lifecycleActionsController.close();
      await bloc.close();
    });

    test('keeps placeholder state when initial load fails', () async {
      final repository = _FakeStreaksRepository(responses: <Object>[StateError('load_failed')]);
      final lifecycleActionsController = StreamController<RestrictionLifecycleAction>.broadcast();
      final bloc = HomeStatsBloc(
        streaksRepository: repository,
        lifecycleActions: lifecycleActionsController.stream,
        nowLocal: () => _asOfLocal,
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state.streakDays, isNull);
      expect(bloc.state.focusedDuration, isNull);
      expect(bloc.state.noDataAvailable, isTrue);

      await lifecycleActionsController.close();
      await bloc.close();
    });

    test('refreshes when lifecycle action is emitted', () async {
      final repository = _FakeStreaksRepository(
        responses: <Object>[
          _snapshot(streakDays: 1, focusedDuration: const Duration(minutes: 10)),
          _snapshot(streakDays: 2, focusedDuration: const Duration(minutes: 20)),
        ],
      );
      final lifecycleActionsController = StreamController<RestrictionLifecycleAction>.broadcast();
      final bloc = HomeStatsBloc(
        streaksRepository: repository,
        lifecycleActions: lifecycleActionsController.stream,
        nowLocal: () => _asOfLocal,
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));
      lifecycleActionsController.add(RestrictionLifecycleAction.pause);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(repository.getGlobalSnapshotCallCount, 2);
      expect(bloc.state.streakDays, 2);
      expect(bloc.state.focusedDuration, const Duration(minutes: 20));

      await lifecycleActionsController.close();
      await bloc.close();
    });

    test('keeps last successful values when refresh fails', () async {
      final repository = _FakeStreaksRepository(
        responses: <Object>[
          _snapshot(streakDays: 4, focusedDuration: const Duration(minutes: 40)),
          StateError('refresh_failed'),
        ],
      );
      final lifecycleActionsController = StreamController<RestrictionLifecycleAction>.broadcast();
      final bloc = HomeStatsBloc(
        streaksRepository: repository,
        lifecycleActions: lifecycleActionsController.stream,
        nowLocal: () => _asOfLocal,
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));
      lifecycleActionsController.add(RestrictionLifecycleAction.resume);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(repository.getGlobalSnapshotCallCount, 2);
      expect(bloc.state.streakDays, 4);
      expect(bloc.state.focusedDuration, const Duration(minutes: 40));
      expect(bloc.state.error, isA<StateError>());

      await lifecycleActionsController.close();
      await bloc.close();
    });
  });
}

final DateTime _asOfLocal = DateTime(2026, 2, 20, 9);

StreakSnapshot _snapshot({required int streakDays, required Duration focusedDuration}) {
  return StreakSnapshot(
    asOfLocal: _asOfLocal,
    targetDurationPerDay: const Duration(minutes: 10),
    todayEffectiveDuration: focusedDuration,
    currentStreakDays: CurrentStreakDays(streakDays),
    bestStreakDays: BestStreakDays(streakDays),
  );
}

class _FakeStreaksRepository implements StreaksRepository {
  _FakeStreaksRepository({required this.responses});

  final List<Object> responses;
  int getGlobalSnapshotCallCount = 0;

  @override
  Future<StreakSnapshot> getGlobalSnapshot({required DateTime nowLocal}) async {
    getGlobalSnapshotCallCount += 1;
    final index = getGlobalSnapshotCallCount - 1;
    final response = responses[index];
    if (response is StreakSnapshot) {
      return response;
    }

    throw response;
  }

  @override
  Future<void> refreshAggregates() async {}
}
