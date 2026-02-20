import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/nfc_chip_config/model/nfc_linked_chip.dart';
import 'package:pauza/src/features/nfc_chip_config/widget/nfc_linked_chip_menu.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class NfcLinkedChipTile extends StatelessWidget {
  const NfcLinkedChipTile({
    required this.chip,
    required this.enabled,
    required this.onRenamePressed,
    required this.onDeletePressed,
    super.key,
  });

  final NfcLinkedChip chip;
  final bool enabled;
  final VoidCallback onRenamePressed;
  final VoidCallback onDeletePressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Material(
      color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.75),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PauzaSpacing.medium,
          vertical: PauzaSpacing.regular,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: PauzaSpacing.small,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: PauzaSpacing.small,
                children: [
                  Text(
                    chip.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    context.l10n.nfcChipConfigLinkedOnDate(
                      chip.createdAt.formatLinkedDate(context),
                    ),
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            NfcLinkedChipMenu(
              enabled: enabled,
              onRenamePressed: onRenamePressed,
              onDeletePressed: onDeletePressed,
            ),
          ],
        ),
      ),
    );
  }
}
