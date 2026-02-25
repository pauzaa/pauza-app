import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/stats/usage_stats/model/stats_section_status.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

typedef StatsSectionFailureBuilder = Widget Function(BuildContext context, VoidCallback? onRetry);

class StatsSectionStateContent extends StatelessWidget {
  const StatsSectionStateContent({
    required this.status,
    required this.successBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    this.failureBuilder,
    this.onRetry,
    this.loadingHeight = 120,
    super.key,
  });

  final StatsSectionStatus status;
  final WidgetBuilder successBuilder;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? emptyBuilder;
  final StatsSectionFailureBuilder? failureBuilder;
  final VoidCallback? onRetry;
  final double loadingHeight;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      StatsSectionStatus.success => successBuilder(context),
      StatsSectionStatus.loading => loadingBuilder?.call(context) ?? _defaultLoading(),
      StatsSectionStatus.failure =>
        failureBuilder?.call(context, onRetry) ?? _defaultFailure(context: context, onRetry: onRetry),
      StatsSectionStatus.empty || StatsSectionStatus.initial => emptyBuilder?.call(context) ?? _defaultEmpty(context),
    };
  }

  Widget _defaultLoading() {
    return SizedBox(height: loadingHeight, child: const Center(child: CircularProgressIndicator()));
  }

  Widget _defaultEmpty(BuildContext context) {
    return Text(context.l10n.statsNoInsightData, style: context.textTheme.bodyLarge);
  }

  Widget _defaultFailure({required BuildContext context, required VoidCallback? onRetry}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(context.l10n.statsInsightLoadFailed, style: context.textTheme.bodyLarge),
        if (onRetry != null) ...<Widget>[
          const SizedBox(height: PauzaSpacing.medium),
          PauzaFilledButton(
            onPressed: onRetry,
            size: PauzaButtonSize.small,
            title: Text(context.l10n.retryButton),
          ),
        ],
      ],
    );
  }
}
