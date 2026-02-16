import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helm/helm.dart';
import 'package:intl/intl.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza/src/features/stats/bloc/stats_bloc.dart';
import 'package:pauza/src/features/stats/bloc/stats_event.dart';
import 'package:pauza/src/features/stats/bloc/stats_state.dart';
import 'package:pauza/src/features/stats/widget/stats_inline_fallback_card.dart';
import 'package:pauza/src/features/stats/widget/stats_ios_usage_report_card.dart';
import 'package:pauza/src/features/stats/widget/stats_total_time_card.dart';
import 'package:pauza/src/features/stats/widget/stats_usage_trend_card.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsUsageTabContent extends StatelessWidget {
  const StatsUsageTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatsBloc, StatsState>(
      builder: (context, state) {
        final l10n = context.l10n;

        return Column(
          children: <Widget>[
            PauzaDateRangePickerCard(
              title: l10n.thisWeek,
              selectedRange: state.window,
              minDate: DateTime(2020),
              maxDate: state.maxDate,
              rangeTextBuilder: (range) =>
                  '${DateFormat('MMM d').format(range.start)} - ${DateFormat('MMM d').format(range.end)}',
              onRangeChanged: (range) {
                context.read<StatsBloc>().add(StatsDateRangePicked(range));
              },
            ),
            const SizedBox(height: PauzaSpacing.large),
            if (state.platform == PauzaPlatform.ios)
              StatsIosUsageReportCard(
                start: state.window.start,
                end: state.window.end,
              )
            else ...<Widget>[
              if (state.hasMissingPermission)
                StatsInlineFallbackCard(
                  title: l10n.statsPermissionRequiredTitle,
                  message: l10n.statsPermissionRequiredBody,
                  actionLabel: l10n.permissionOpenSettingsButton,
                  onActionPressed: () {
                    HelmRouter.push(context, PauzaRoutes.permissions);
                  },
                )
              else if (state.error != null)
                StatsInlineFallbackCard(
                  title: l10n.errorTitle,
                  message: l10n.statsLoadFailed,
                  actionLabel: l10n.retryButton,
                  onActionPressed: () {
                    context.read<StatsBloc>().add(
                      const StatsRefreshRequested(),
                    );
                  },
                )
              else if (state.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (state.summary != null) ...<Widget>[
                StatsTotalTimeCard(summary: state.summary!),
                const SizedBox(height: PauzaSpacing.large),
                StatsUsageTrendCard(summary: state.summary!),
              ] else
                StatsInlineFallbackCard(
                  title: l10n.emptyStateMessage,
                  message: l10n.statsNoUsageData,
                ),
            ],
          ],
        );
      },
    );
  }
}
