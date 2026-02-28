import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/stats/usage_stats/model/app_usage_entry.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsUsageAppRow extends StatelessWidget {
  const StatsUsageAppRow({required this.entry, super.key});

  final AppUsageEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PauzaSpacing.small),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(PauzaCornerRadius.small),
                child: entry.appInfo.icon != null
                    ? Image.memory(
                        entry.appInfo.icon!,
                        width: 32,
                        height: 32,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.android, size: 32, color: colorScheme.onSurfaceVariant),
                      )
                    : Icon(Icons.android, size: 32, color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(width: PauzaSpacing.regular),
              Expanded(
                child: Text(entry.appInfo.name, style: textTheme.bodyLarge, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: PauzaSpacing.small),
              Text(
                entry.totalDuration.formatDurationLabel(l10n),
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: PauzaSpacing.tiny),
          ClipRRect(
            borderRadius: BorderRadius.circular(PauzaCornerRadius.small),
            child: LinearProgressIndicator(
              value: entry.shareOfTotal,
              minHeight: 4,
              backgroundColor: colorScheme.outlineVariant,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
