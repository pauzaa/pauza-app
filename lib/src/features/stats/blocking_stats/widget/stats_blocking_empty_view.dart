import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsBlockingEmptyView extends StatelessWidget {
  const StatsBlockingEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PauzaSpacing.xLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.block_outlined, size: PauzaIconSizes.xLarge, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: PauzaSpacing.medium),
          Text(
            l10n.statsBlockingNoData,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
