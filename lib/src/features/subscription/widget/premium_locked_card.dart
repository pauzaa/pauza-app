import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/subscription/widget/paywall_screen.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class PremiumLockedCard extends StatelessWidget {
  const PremiumLockedCard({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: PauzaSpacing.small),
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(PauzaCornerRadius.medium),
          ),
          child: Padding(
            padding: const EdgeInsets.all(PauzaSpacing.medium),
            child: Row(
              children: [
                Icon(Icons.lock_rounded, size: 20, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: PauzaSpacing.small),
                Expanded(
                  child: Text(
                    l10n.premiumLockedMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
                TextButton(onPressed: () => PaywallScreen.show(context), child: Text(l10n.premiumUpgradeButton)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
