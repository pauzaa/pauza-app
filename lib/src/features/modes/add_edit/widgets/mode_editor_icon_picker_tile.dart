import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_card.dart';
import 'package:pauza/src/features/modes/common/model/mode_icon.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

final class ModeEditorIconPickerTile extends StatelessWidget {
  const ModeEditorIconPickerTile({
    required this.title,
    required this.subtitle,
    required this.selectedIcon,
    required this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final ModeIcon selectedIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ModeEditorCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
        child: Row(
          spacing: PauzaSpacing.medium,
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                color: context.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(PauzaCornerRadius.medium),
              ),
              child: SizedBox(
                width: PauzaFormSizes.xSmall,
                height: PauzaFormSizes.xSmall,
                child: Icon(selectedIcon.icon, color: context.colorScheme.primary),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: PauzaSpacing.small,
                children: <Widget>[
                  Text(
                    title,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: context.colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(PauzaCornerRadius.full),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PauzaSpacing.medium,
                  vertical: PauzaSpacing.small,
                ),
                child: Text(
                  selectedIcon.localizedLabel(context.l10n),
                  style: context.textTheme.labelLarge?.copyWith(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
