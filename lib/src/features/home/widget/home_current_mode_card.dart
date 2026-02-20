import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class HomeCurrentModeCard extends StatelessWidget {
  const HomeCurrentModeCard(this.mode, {required this.onTap, super.key});

  final Mode? mode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final borderRadius = BorderRadius.circular(PauzaCornerRadius.large);

    return Material(
      color: context.colorScheme.surfaceContainerLowest.withValues(alpha: 0.75),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(
          color: context.colorScheme.primary.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Padding(
          padding: const EdgeInsets.all(PauzaSpacing.medium),
          child: Row(
            spacing: PauzaSpacing.medium,
            children: <Widget>[
              SizedBox(
                width: PauzaFormSizes.small,
                height: PauzaFormSizes.small,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      PauzaCornerRadius.medium,
                    ),
                    border: Border.all(
                      color: context.colorScheme.primary.withValues(
                        alpha: 0.35,
                      ),
                    ),
                  ),
                  child: Icon(
                    mode == null ? Icons.psychology : mode!.icon.icon,
                    color: context.colorScheme.primary,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: PauzaSpacing.small,
                  children: <Widget>[
                    Text(
                      l10n.homeCurrentModeLabel.toUpperCase(),
                      style: context.textTheme.labelLarge?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      mode?.title ?? l10n.noModesEmptyState,
                      style: context.textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: PauzaFormSizes.small,
                height: PauzaFormSizes.small,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colorScheme.surfaceContainerHigh,
                    border: Border.all(
                      color: context.colorScheme.outlineVariant,
                    ),
                  ),
                  child: Icon(
                    Icons.expand_more,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
