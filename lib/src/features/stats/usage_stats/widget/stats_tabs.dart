import 'package:flutter/material.dart';
import 'package:pauza/src/features/stats/common/model/stats_tab.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class StatsTabs extends StatelessWidget {
  const StatsTabs({
    required this.usageLabel,
    required this.blockingLabel,
    required this.selectedTab,
    required this.onChanged,
    super.key,
  });

  final String usageLabel;
  final String blockingLabel;
  final StatsTab selectedTab;
  final ValueChanged<StatsTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
        border: Border.all(color: context.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PauzaSpacing.small),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _StatsTabButton(
                title: usageLabel,
                onTap: () => onChanged(StatsTab.usage),
                isSelected: selectedTab == StatsTab.usage,
              ),
            ),
            const SizedBox(width: PauzaSpacing.small),
            Expanded(
              child: _StatsTabButton(
                title: blockingLabel,
                onTap: () => onChanged(StatsTab.blocking),
                isSelected: selectedTab == StatsTab.blocking,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _StatsTabButton extends StatelessWidget {
  const _StatsTabButton({required this.title, required this.isSelected, required this.onTap});

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(PauzaCornerRadius.medium),
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isSelected ? context.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(PauzaCornerRadius.medium),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: PauzaSpacing.regular),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? context.colorScheme.onPrimary
                  : context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
