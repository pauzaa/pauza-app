import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.g.dart';
import 'package:pauza/src/features/stats/usage_stats/bloc/stats_bloc.dart';
import 'package:pauza/src/features/stats/usage_stats/bloc/stats_event.dart';
import 'package:pauza/src/features/stats/usage_stats/data/stats_usage_repository.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_usage_tab_content.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

void main() {
  testWidgets('renders without crashing', (tester) async {
    final bloc = StatsBloc(
      usageRepository: _WidgetStatsUsageRepository(),
      platform: PauzaPlatform.android,
    )..add(const StatsStarted());
    addTearDown(bloc.close);

    await tester.pumpWidget(_TestApp(bloc: bloc));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify the widget renders without crashing
    expect(find.byType(StatsUsageTabContent), findsOneWidget);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.bloc});

  final StatsBloc bloc;

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
      theme: PauzaTheme.dark,
      home: Scaffold(
        body: SingleChildScrollView(
          child: BlocProvider<StatsBloc>.value(
            value: bloc,
            child: const StatsUsageTabContent(),
          ),
        ),
      ),
    );
  }
}

class _WidgetStatsUsageRepository implements StatsUsageRepository {
  @override
  Future<IList<UsageStats>> getUsageStats({
    required DateTime start,
    required DateTime end,
  }) async {
    return <UsageStats>[
      UsageStats(
        appInfo: const AndroidAppInfo(
          packageId: AppIdentifier.android('social.app'),
          name: 'social.app',
          category: 'Social',
        ),
        totalDuration: const Duration(minutes: 120),
        totalLaunchCount: 1,
        bucketStart: start,
        bucketEnd: end,
        lastTimeUsed: start,
      ),
    ].lock;
  }
}
