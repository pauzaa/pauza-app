import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:pauza/src/features/stats/blocking_stats/bloc/stats_blocking_bloc.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/blocking_daily_point.dart';
import 'package:pauza/src/features/stats/blocking_stats/model/blocking_stats_snapshot.dart';
import 'package:pauza/src/features/stats/blocking_stats/widget/stats_blocking_tab_content.dart';
import 'package:pauza/src/features/streaks/common/model/streak_types.dart';

import '../../usage_stats/helpers/pump_stats_widget.dart';
import '../helpers/fake_stats_blocking_repository.dart';

void main() {
  testWidgets('renders KPI sections and charts for successful snapshot', (tester) async {
    final repo = FakeStatsBlockingRepository(responses: <Object>[_snapshot()]);
    final bloc = StatsBlockingBloc(repository: repo)..add(const StatsBlockingStarted());
    addTearDown(bloc.close);

    await pumpStatsWidget(
      tester,
      BlocProvider<StatsBlockingBloc>.value(value: bloc, child: const StatsBlockingTabContent()),
      scrollable: true,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('BLOCKING KPIS'), findsOneWidget);
    expect(find.text('RANGE OVERVIEW'), findsOneWidget);
    expect(find.text('DAILY EFFECTIVE BLOCKING'), findsOneWidget);
    expect(find.text('PAUSE COMPOSITION'), findsOneWidget);
    expect(find.text('Current streak'), findsOneWidget);
    expect(find.text('Avg pause duration'), findsOneWidget);
  });
}

BlockingStatsSnapshot _snapshot() {
  return const BlockingStatsSnapshot(
    currentStreakDays: 3,
    longestStreakDays: 9,
    averageRestrictionSessionDuration: Duration(minutes: 15),
    longestRestrictionSessionDuration: Duration(minutes: 40),
    averagePausesPerSession: 1.5,
    averagePauseDuration: Duration(minutes: 3),
    completedSessionsCount: 4,
    totalEffectiveBlockedDuration: Duration(minutes: 50),
    totalPausedDuration: Duration(minutes: 10),
    dailyTrend: IListConst<BlockingDailyPoint>(<BlockingDailyPoint>[
      BlockingDailyPoint(localDay: LocalDayKey('2026-02-01'), effectiveDuration: Duration(minutes: 20)),
      BlockingDailyPoint(localDay: LocalDayKey('2026-02-02'), effectiveDuration: Duration(minutes: 30)),
    ]),
  );
}
