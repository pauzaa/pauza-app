import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/stats/blocking_stats/bloc/stats_blocking_bloc.dart';
import 'package:pauza/src/features/stats/blocking_stats/widget/stats_blocking_daily_trend_card.dart';
import 'package:pauza/src/features/stats/blocking_stats/widget/stats_blocking_kpi_grid.dart';
import 'package:pauza/src/features/stats/blocking_stats/widget/stats_blocking_overview_card.dart';
import 'package:pauza/src/features/stats/blocking_stats/widget/stats_blocking_pause_composition_card.dart';
import 'package:pauza/src/features/stats/common/widget/stats_date_range_picker_card.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_inline_fallback_card.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsBlockingTabContent extends StatelessWidget {
  const StatsBlockingTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatsBlockingBloc, StatsBlockingState>(
      builder: (context, state) {
        return Column(
          spacing: PauzaSpacing.large,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StatsDateRangePickerCard(
              selectedRange: state.window,
              maxDate: state.maxDate,
              onRangeChanged: (range) {
                context.read<StatsBlockingBloc>().add(StatsBlockingDateRangePicked(range));
              },
            ),
            _buildContent(context: context, state: state),
          ],
        );
      },
    );
  }

  Widget _buildContent({required BuildContext context, required StatsBlockingState state}) {
    final l10n = context.l10n;

    if (state.hasError) {
      return StatsInlineFallbackCard(
        title: l10n.errorTitle,
        message: l10n.statsBlockingLoadFailed,
        actionLabel: l10n.retryButton,
        onActionPressed: () {
          context.read<StatsBlockingBloc>().add(const StatsBlockingRefreshRequested());
        },
      );
    }

    if (state.isLoading && state.snapshot == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final snapshot = state.snapshot;
    if (snapshot == null || snapshot.isEmpty) {
      return StatsInlineFallbackCard(title: l10n.emptyStateMessage, message: l10n.statsBlockingNoData);
    }

    return Column(
      spacing: PauzaSpacing.large,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        StatsBlockingKpiGrid(snapshot: snapshot),
        StatsBlockingOverviewCard(snapshot: snapshot),
        StatsBlockingDailyTrendCard(snapshot: snapshot),
        StatsBlockingPauseCompositionCard(snapshot: snapshot),
      ],
    );
  }
}
