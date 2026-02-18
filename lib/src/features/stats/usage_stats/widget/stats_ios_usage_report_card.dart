import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/stats/usage_stats/bloc/stats_bloc.dart';
import 'package:pauza/src/features/stats/usage_stats/bloc/stats_state.dart';
import 'package:pauza/src/features/stats/usage_stats/widget/stats_inline_fallback_card.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsIosUsageReportCard extends StatelessWidget {
  const StatsIosUsageReportCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
        border: Border.all(color: context.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PauzaSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              context.l10n.usageTrend.toUpperCase(),
              style: context.textTheme.headlineSmall?.copyWith(color: context.colorScheme.onSurfaceVariant, letterSpacing: 2),
            ),
            const SizedBox(height: PauzaSpacing.medium),
            SizedBox(
              height: 280,
              child: BlocSelector<StatsBloc, StatsState, DateTimeRange>(
                selector: (state) {
                  return state.window;
                },
                builder: (context, state) {
                  return IOSUsageReportView(
                    reportContext: 'daily',
                    startDate: state.start,
                    endDate: state.end,
                    fallback: StatsInlineFallbackCard(
                      title: context.l10n.statsIosReportUnavailableTitle,
                      message: context.l10n.statsIosReportUnavailableBody,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
