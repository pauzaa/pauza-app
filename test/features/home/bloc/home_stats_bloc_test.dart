import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pauza/src/features/home/bloc/home_stats_bloc.dart';
import 'package:pauza/src/features/streaks/common/model/streak_types.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

import '../../../helpers/helpers.dart';

final DateTime _asOfLocal = DateTime(2026, 2, 20, 9);

void main() {
  late MockStreaksRepository repository;
  late StreamController<RestrictionLifecycleAction> lifecycleActionsController;

  setUpAll(() {
    registerTestFallbackValues();
  });

  setUp(() {
    repository = MockStreaksRepository();
    lifecycleActionsController = StreamController<RestrictionLifecycleAction>.broadcast();
  });

  tearDown(() async {
    await lifecycleActionsController.close();
  });

  group('HomeStatsBloc', () {
    blocTest<HomeStatsBloc, HomeStatsState>(
      'loads snapshot on initialization and maps values',
      setUp: () {
        when(() => repository.getGlobalSnapshot(nowLocal: any(named: 'nowLocal'))).thenAnswer(
          (_) async => makeStreakSnapshot(
            asOfLocal: _asOfLocal,
            currentStreakDays: const CurrentStreakDays(3),
            bestStreakDays: const BestStreakDays(3),
            todayEffectiveDuration: const Duration(minutes: 27),
          ),
        );
      },
      build: () => HomeStatsBloc(
        streaksRepository: repository,
        lifecycleActions: lifecycleActionsController.stream,
        nowLocal: () => _asOfLocal,
      ),
      act: (bloc) => bloc.add(const HomeStatsLoadRequested()),
      expect: () => <HomeStatsState>[
        const HomeStatsState(isRefreshing: true, streakDays: null, focusedDuration: null),
        const HomeStatsState(isRefreshing: false, streakDays: 3, focusedDuration: Duration(minutes: 27)),
      ],
      verify: (_) {
        verify(() => repository.getGlobalSnapshot(nowLocal: any(named: 'nowLocal'))).called(1);
      },
    );

    final loadError = StateError('load_failed');

    blocTest<HomeStatsBloc, HomeStatsState>(
      'keeps placeholder state when initial load fails',
      setUp: () {
        when(() => repository.getGlobalSnapshot(nowLocal: any(named: 'nowLocal'))).thenThrow(loadError);
      },
      build: () => HomeStatsBloc(
        streaksRepository: repository,
        lifecycleActions: lifecycleActionsController.stream,
        nowLocal: () => _asOfLocal,
      ),
      act: (bloc) => bloc.add(const HomeStatsLoadRequested()),
      expect: () => <HomeStatsState>[
        const HomeStatsState(isRefreshing: true, streakDays: null, focusedDuration: null),
        HomeStatsState(isRefreshing: false, streakDays: null, focusedDuration: null, error: loadError),
      ],
      verify: (bloc) {
        expect(bloc.state.noDataAvailable, isTrue);
      },
    );

    blocTest<HomeStatsBloc, HomeStatsState>(
      'refreshes when lifecycle action is emitted',
      setUp: () {
        var callCount = 0;
        when(() => repository.getGlobalSnapshot(nowLocal: any(named: 'nowLocal'))).thenAnswer((_) async {
          callCount += 1;
          if (callCount == 1) {
            return makeStreakSnapshot(
              asOfLocal: _asOfLocal,
              currentStreakDays: const CurrentStreakDays(1),
              bestStreakDays: const BestStreakDays(1),
              todayEffectiveDuration: const Duration(minutes: 10),
            );
          }
          return makeStreakSnapshot(
            asOfLocal: _asOfLocal,
            currentStreakDays: const CurrentStreakDays(2),
            bestStreakDays: const BestStreakDays(2),
            todayEffectiveDuration: const Duration(minutes: 20),
          );
        });
      },
      build: () => HomeStatsBloc(
        streaksRepository: repository,
        lifecycleActions: lifecycleActionsController.stream,
        nowLocal: () => _asOfLocal,
      ),
      act: (bloc) async {
        bloc.add(const HomeStatsLoadRequested());
        await bloc.stream.firstWhere((s) => !s.isRefreshing);
        lifecycleActionsController.add(RestrictionLifecycleAction.pause);
      },
      expect: () => <HomeStatsState>[
        const HomeStatsState(isRefreshing: true, streakDays: null, focusedDuration: null),
        const HomeStatsState(isRefreshing: false, streakDays: 1, focusedDuration: Duration(minutes: 10)),
        const HomeStatsState(isRefreshing: true, streakDays: 1, focusedDuration: Duration(minutes: 10)),
        const HomeStatsState(isRefreshing: false, streakDays: 2, focusedDuration: Duration(minutes: 20)),
      ],
      verify: (_) {
        verify(() => repository.getGlobalSnapshot(nowLocal: any(named: 'nowLocal'))).called(2);
      },
    );

    final refreshError = StateError('refresh_failed');

    blocTest<HomeStatsBloc, HomeStatsState>(
      'keeps last successful values when refresh fails',
      setUp: () {
        var callCount = 0;
        when(() => repository.getGlobalSnapshot(nowLocal: any(named: 'nowLocal'))).thenAnswer((_) async {
          callCount += 1;
          if (callCount == 1) {
            return makeStreakSnapshot(
              asOfLocal: _asOfLocal,
              currentStreakDays: const CurrentStreakDays(4),
              bestStreakDays: const BestStreakDays(4),
              todayEffectiveDuration: const Duration(minutes: 40),
            );
          }
          throw refreshError;
        });
      },
      build: () => HomeStatsBloc(
        streaksRepository: repository,
        lifecycleActions: lifecycleActionsController.stream,
        nowLocal: () => _asOfLocal,
      ),
      act: (bloc) async {
        bloc.add(const HomeStatsLoadRequested());
        await bloc.stream.firstWhere((s) => !s.isRefreshing);
        lifecycleActionsController.add(RestrictionLifecycleAction.resume);
      },
      expect: () => <HomeStatsState>[
        const HomeStatsState(isRefreshing: true, streakDays: null, focusedDuration: null),
        const HomeStatsState(isRefreshing: false, streakDays: 4, focusedDuration: Duration(minutes: 40)),
        const HomeStatsState(isRefreshing: true, streakDays: 4, focusedDuration: Duration(minutes: 40)),
        HomeStatsState(
          isRefreshing: false,
          streakDays: 4,
          focusedDuration: const Duration(minutes: 40),
          error: refreshError,
        ),
      ],
      verify: (_) {
        verify(() => repository.getGlobalSnapshot(nowLocal: any(named: 'nowLocal'))).called(2);
      },
    );
  });
}
