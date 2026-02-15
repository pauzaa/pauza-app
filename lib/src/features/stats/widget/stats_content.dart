import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/stats/bloc/stats_bloc.dart';
import 'package:pauza/src/features/stats/bloc/stats_event.dart';
import 'package:pauza/src/features/stats/bloc/stats_state.dart';
import 'package:pauza/src/features/stats/model/stats_tab.dart';
import 'package:pauza/src/features/stats/widget/stats_blocking_tab_placeholder.dart';
import 'package:pauza/src/features/stats/widget/stats_tabs.dart';
import 'package:pauza/src/features/stats/widget/stats_usage_tab_content.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsContent extends StatelessWidget {
  const StatsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<StatsBloc, StatsState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: PauzaSpacing.large,
                vertical: PauzaSpacing.large,
              ),
              children: <Widget>[
                PauzaDashboardAppBar(
                  greeting: l10n.deviceUsage,
                  title: l10n.homeDashboardTitle,
                  showSettingsButton: false,
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: PauzaSpacing.large),
                StatsTabs(
                  selectedTab: state.selectedTab,
                  usageLabel: l10n.usageStatsTab,
                  blockingLabel: l10n.blockingStatsTab,
                  onChanged: (tab) {
                    context.read<StatsBloc>().add(StatsTabChanged(tab));
                  },
                ),
                const SizedBox(height: PauzaSpacing.large),
                switch (state.selectedTab) {
                  StatsTab.usage => const StatsUsageTabContent(),
                  StatsTab.blocking => const StatsBlockingTabPlaceholder(),
                },
              ],
            );
          },
        ),
      ),
    );
  }
}
