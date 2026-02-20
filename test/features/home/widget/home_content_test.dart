import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.g.dart';
import 'package:pauza/src/features/home/bloc/blocking_bloc.dart';
import 'package:pauza/src/features/home/bloc/home_stats_bloc.dart';
import 'package:pauza/src/features/home/data/pauza_blocking_repository.dart';
import 'package:pauza/src/features/home/widget/home_content.dart';
import 'package:pauza/src/features/home/widget/home_current_mode_card.dart';
import 'package:pauza/src/features/home/widget/home_session_button.dart';
import 'package:pauza/src/features/home/widget/home_stats_pill.dart';
import 'package:pauza/src/features/modes/common/data/modes_repository.dart';
import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:pauza/src/features/modes/common/model/mode_icon.dart';
import 'package:pauza/src/features/modes/common/model/mode_upsert.dart';
import 'package:pauza/src/features/modes/list/bloc/modes_bloc.dart';
import 'package:pauza/src/features/streaks/common/model/streak_types.dart';
import 'package:pauza/src/features/streaks/common/model/streak_snapshot.dart';
import 'package:pauza/src/features/streaks/data/streaks_repository.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

void main() {
  group('HomeContent', () {
    testWidgets('renders default home body when session is not active', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 3000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final modesBloc = _TestModesListBloc();
      final blockingBloc = _TestBlockingBloc();

      await tester.pumpWidget(_TestApp(modesBloc: modesBloc, blockingBloc: blockingBloc));
      await tester.pump();

      expect(find.byType(HomeStatsPill), findsOneWidget);
      expect(find.byType(HomeCurrentModeCard), findsOneWidget);
      expect(find.byType(HomeSessionButton), findsOneWidget);
      expect(find.text('1m'), findsNothing);
      expect(tester.widget<HomeSessionButton>(find.byType(HomeSessionButton)).isActiveSession, isFalse);

      addTearDown(modesBloc.close);
      addTearDown(blockingBloc.close);
    });

    testWidgets('renders loaded streak and duration from HomeStatsBloc', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 3000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final modesBloc = _TestModesListBloc();
      final blockingBloc = _TestBlockingBloc();

      await tester.pumpWidget(
        _TestApp(
          modesBloc: modesBloc,
          blockingBloc: blockingBloc,
          streaksRepository: _SnapshotStreaksRepository(
            snapshot: _snapshot(streakDays: 2, focusedDuration: const Duration(minutes: 95)),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('2 Day Streak'), findsOneWidget);
      expect(find.text('1h 35m'), findsOneWidget);

      addTearDown(modesBloc.close);
      addTearDown(blockingBloc.close);
    });

    testWidgets('renders placeholder while first stats load is in-flight', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 3000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final modesBloc = _TestModesListBloc();
      final blockingBloc = _TestBlockingBloc();
      final repository = _DeferredStreaksRepository();

      await tester.pumpWidget(
        _TestApp(modesBloc: modesBloc, blockingBloc: blockingBloc, streaksRepository: repository),
      );
      await tester.pump();

      expect(find.text('--'), findsNWidgets(2));

      repository.complete(_snapshot(streakDays: 1, focusedDuration: const Duration(minutes: 10)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));

      expect(find.text('1 Day Streak'), findsOneWidget);
      expect(find.text('0h 10m'), findsOneWidget);

      addTearDown(modesBloc.close);
      addTearDown(blockingBloc.close);
    });
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.modesBloc,
    required this.blockingBloc,
    this.streaksRepository = const _NoopStreaksRepository(),
  });

  final ModesListBloc modesBloc;
  final BlockingBloc blockingBloc;
  final StreaksRepository streaksRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: PauzaTheme.light,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ModesListBloc>.value(value: modesBloc),
          BlocProvider<BlockingBloc>.value(value: blockingBloc),
          BlocProvider<HomeStatsBloc>(
            create: (context) => HomeStatsBloc(
              streaksRepository: streaksRepository,
              lifecycleActions: const Stream<RestrictionLifecycleAction>.empty(),
            ),
          ),
        ],
        child: const HomeContent(),
      ),
    );
  }
}

class _TestModesListBloc extends ModesListBloc {
  _TestModesListBloc() : super(modesRepository: _NoopModesRepository());
}

class _TestBlockingBloc extends BlockingBloc {
  _TestBlockingBloc() : super(blockingRepository: _NoopBlockingRepository());

  BlockingEvent? lastEvent;

  @override
  void add(BlockingEvent event) {
    lastEvent = event;
    super.add(event);
  }

  void emitForTest(BlockingState value) {
    emit(value);
  }
}

class _NoopModesRepository implements ModesRepository {
  @override
  Future<void> createMode(ModeUpsertDTO request) async {}

  @override
  Future<void> deleteMode(String modeId) async {}

  @override
  Future<Mode> getMode(String modeId) async => _mode;

  @override
  Future<List<Mode>> getModes() async => <Mode>[_mode];

  @override
  Future<void> updateMode({required String modeId, required ModeUpsertDTO request}) async {}

  static final Mode _mode = Mode(
    id: 'mode-1',
    title: 'Mode 1',
    textOnScreen: 'Focus',
    description: null,
    allowedPausesCount: 3,
    icon: ModeIconCatalog.defaultIcon,
    schedule: null,
    blockedAppIds: const ISet<AppIdentifier>.empty(),
    createdAt: DateTime.now().toUtc(),
    updatedAt: DateTime.now().toUtc(),
  );

  @override
  Stream<void> watchModes() => const Stream.empty();

  @override
  void dispose() {}
}

class _NoopBlockingRepository implements BlockingRepository {
  @override
  Stream<RestrictionLifecycleAction> get lifecycleActions => const Stream<RestrictionLifecycleAction>.empty();

  @override
  Future<RestrictionState> getRestrictionSession() async {
    return const RestrictionState(
      isScheduleEnabled: false,
      isInScheduleNow: false,
      pausedUntil: null,
      activeMode: null,
      activeModeSource: RestrictionModeSource.none,
      currentSessionEvents: <RestrictionLifecycleEvent>[],
    );
  }

  @override
  Future<void> pauseBlocking(Duration duration) async {}

  @override
  Future<void> resumeBlocking() async {}

  @override
  Future<void> startBlocking({required Mode mode, required ShieldConfiguration? shield}) async {}

  @override
  Future<void> stopBlocking() async {}

  @override
  Future<void> syncRestrictionLifecycleEvents() async {}

  @override
  void dispose() {}
}

final class _NoopStreaksRepository implements StreaksRepository {
  const _NoopStreaksRepository();

  @override
  Future<StreakSnapshot> getGlobalSnapshot({required DateTime nowLocal}) async {
    return StreakSnapshot.zero(asOfLocal: nowLocal);
  }

  @override
  Future<void> refreshAggregates() async {}
}

final class _SnapshotStreaksRepository implements StreaksRepository {
  const _SnapshotStreaksRepository({required this.snapshot});

  final StreakSnapshot snapshot;

  @override
  Future<StreakSnapshot> getGlobalSnapshot({required DateTime nowLocal}) async {
    return snapshot;
  }

  @override
  Future<void> refreshAggregates() async {}
}

final class _DeferredStreaksRepository implements StreaksRepository {
  final Completer<StreakSnapshot> _completer = Completer<StreakSnapshot>();

  void complete(StreakSnapshot snapshot) {
    _completer.complete(snapshot);
  }

  @override
  Future<StreakSnapshot> getGlobalSnapshot({required DateTime nowLocal}) {
    return _completer.future;
  }

  @override
  Future<void> refreshAggregates() async {}
}

StreakSnapshot _snapshot({required int streakDays, required Duration focusedDuration}) {
  return StreakSnapshot(
    asOfLocal: DateTime(2026, 2, 20, 9),
    targetDurationPerDay: const Duration(minutes: 10),
    todayEffectiveDuration: focusedDuration,
    currentStreakDays: CurrentStreakDays(streakDays),
    bestStreakDays: BestStreakDays(streakDays),
  );
}
