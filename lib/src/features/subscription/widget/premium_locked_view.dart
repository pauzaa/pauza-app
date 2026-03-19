import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/subscription/widget/paywall_screen.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class PremiumLockedView extends StatelessWidget {
  const PremiumLockedView({required this.featureTitle, this.featureDescription, super.key});

  final String featureTitle;
  final String? featureDescription;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PauzaSpacing.extraLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(PauzaCornerRadius.medium),
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(PauzaSpacing.medium),
                child: Icon(Icons.lock_rounded, size: 48, color: theme.colorScheme.primary),
              ),
            ),
            const SizedBox(height: PauzaSpacing.large),
            Text(featureTitle, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: PauzaSpacing.small),
            Text(
              featureDescription ?? l10n.premiumLockedMessage,
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: PauzaSpacing.extraLarge),
            PauzaFilledButton(title: Text(l10n.premiumUnlockButton), onPressed: () => PaywallScreen.show(context)),
          ],
        ),
      ),
    );
  }
}
