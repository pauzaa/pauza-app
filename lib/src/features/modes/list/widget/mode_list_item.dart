import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/modes/common/model/mode.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class ModeListItem extends StatelessWidget {
  const ModeListItem({
    required this.mode,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final Mode mode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final description = mode.description?.trim();
    final subtitle = description == null || description.isEmpty
        ? l10n.blockedAppsCountLabel(mode.blockedAppIds.length)
        : description;

    final borderColor = isSelected
        ? colorScheme.primary.withValues(alpha: 0.9)
        : colorScheme.outlineVariant.withValues(alpha: 0.75);
    final backgroundColor = isSelected
        ? colorScheme.primary.withValues(alpha: 0.08)
        : colorScheme.surfaceContainerLowest.withValues(alpha: 0.45);

    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
        side: BorderSide(color: borderColor, width: isSelected ? 1.8 : 1.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.28),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
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
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(
                        PauzaCornerRadius.medium,
                      ),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary.withValues(alpha: 0.45)
                            : colorScheme.outlineVariant.withValues(
                                alpha: 0.55,
                              ),
                      ),
                    ),
                    child: Icon(
                      mode.icon.icon,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      size: PauzaIconSizes.small,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: PauzaSpacing.small,
                    children: <Widget>[
                      Text(
                        mode.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  spacing: PauzaSpacing.small,
                  children: <Widget>[
                    IconButton.filledTonal(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit),
                      visualDensity: VisualDensity.compact,
                      iconSize: PauzaIconSizes.small,
                    ),
                    IconButton.filledTonal(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                      color: colorScheme.error,
                      style: IconButton.styleFrom(
                        foregroundColor: colorScheme.error,
                        backgroundColor: colorScheme.surfaceContainerHigh,
                      ),
                      visualDensity: VisualDensity.compact,
                      iconSize: PauzaIconSizes.small,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
