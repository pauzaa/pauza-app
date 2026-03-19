import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza/src/features/stats/blocking_stats/bloc/stats_blocking_bloc.dart';
import 'package:pauza/src/features/stats/blocking_stats/widget/stats_blocking_tab_content.dart';
import 'package:pauza/src/features/stats/common/model/stats_tab.dart';
import 'package:pauza/src/features/stats/common/widget/stats_tabs.dart';
import 'package:pauza/src/features/stats/usage_stats/bloc/stats_usage_bloc.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_usage_tab_content.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  static void show(BuildContext context) {
    HelmRouter.push(context, PauzaRoutes.stats);
  }

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late final ValueNotifier<StatsTab> _selectedTab;

  @override
  void initState() {
    _selectedTab = ValueNotifier(StatsTab.usage);
    super.initState();
  }

  @override
  void dispose() {
    _selectedTab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return MultiBlocProvider(
      providers: [
        BlocProvider<StatsBlockingBloc>(
          create: (context) => StatsBlockingBloc(repository: RootScope.of(context).statsBlockingRepository),
        ),
        BlocProvider<StatsUsageBloc>(
          create: (context) =>
              StatsUsageBloc(repository: RootScope.of(context).statsUsageRepository)..add(const StatsUsageStarted()),
        ),
      ],
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: PauzaSpacing.large, vertical: PauzaSpacing.large),
            children: <Widget>[
              PauzaDashboardAppBar(title: l10n.deviceUsage),
              ValueListenableBuilder(
                valueListenable: _selectedTab,
                builder: (context, value, child) {
                  return StatsTabs(
                    usageLabel: l10n.usageStatsTab,
                    blockingLabel: l10n.blockingStatsTab,
                    selectedTab: value,
                    onChanged: (tab) {
                      _selectedTab.value = tab;
                    },
                  );
                },
              ),
              ValueListenableBuilder(
                valueListenable: _selectedTab,
                builder: (context, value, child) {
                  return switch (value) {
                    StatsTab.usage => const StatsUsageTabContent(),
                    StatsTab.blocking => const _LazyBlockingTabContent(),
                  };
                },
              ),
            ].interleaved(const SizedBox(height: PauzaSpacing.large)).toList(),
          ),
        ),
      ),
    );
  }
}

class _LazyBlockingTabContent extends StatefulWidget {
  const _LazyBlockingTabContent();

  @override
  State<_LazyBlockingTabContent> createState() => _LazyBlockingTabContentState();
}

class _LazyBlockingTabContentState extends State<_LazyBlockingTabContent> {
  @override
  void initState() {
    super.initState();
    context.read<StatsBlockingBloc>().add(const StatsBlockingStarted());
  }

  @override
  Widget build(BuildContext context) => const StatsBlockingTabContent();
}
