import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/nfc_chip_config/model/nfc_linked_chip.dart';
import 'package:pauza/src/features/nfc_chip_config/widget/nfc_linked_chip_tile.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class NfcLinkedChipList extends StatelessWidget {
  const NfcLinkedChipList({
    required this.linkedChips,
    required this.isLoading,
    required this.onRenamePressed,
    required this.onDeletePressed,
    super.key,
  });

  final IList<NfcLinkedChip> linkedChips;
  final bool isLoading;
  final ValueChanged<NfcLinkedChip> onRenamePressed;
  final ValueChanged<NfcLinkedChip> onDeletePressed;

  @override
  Widget build(BuildContext context) {
    if (linkedChips.isEmpty) {
      return _NfcLinkedChipsEmptyState(isLoading: isLoading);
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: linkedChips.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: PauzaSpacing.medium),
      itemBuilder: (context, index) {
        final chip = linkedChips[index];
        return NfcLinkedChipTile(
          chip: chip,
          enabled: !isLoading,
          onRenamePressed: () => onRenamePressed(chip),
          onDeletePressed: () => onDeletePressed(chip),
        );
      },
    );
  }
}

class _NfcLinkedChipsEmptyState extends StatelessWidget {
  const _NfcLinkedChipsEmptyState({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PauzaSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: PauzaSpacing.small,
          children: [
            Text(
              context.l10n.nfcChipConfigNoTagsTitle,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              isLoading
                  ? context.l10n.loadingLabel
                  : context.l10n.nfcChipConfigNoTagsBody,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
