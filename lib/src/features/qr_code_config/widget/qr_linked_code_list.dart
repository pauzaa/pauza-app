import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/qr_code_config/model/qr_linked_code.dart';
import 'package:pauza/src/features/qr_code_config/widget/qr_linked_code_tile.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class QrLinkedCodeList extends StatelessWidget {
  const QrLinkedCodeList({
    required this.linkedCodes,
    required this.isLoading,
    required this.onRenamePressed,
    required this.onDeletePressed,
    required this.onPreviewPressed,
    super.key,
  });

  final IList<QrLinkedCode> linkedCodes;
  final bool isLoading;
  final ValueChanged<QrLinkedCode> onRenamePressed;
  final ValueChanged<QrLinkedCode> onDeletePressed;
  final ValueChanged<QrLinkedCode> onPreviewPressed;

  @override
  Widget build(BuildContext context) {
    if (linkedCodes.isEmpty) {
      return _QrLinkedCodesEmptyState(isLoading: isLoading);
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: linkedCodes.length,
      separatorBuilder: (context, index) => const SizedBox(height: PauzaSpacing.medium),
      itemBuilder: (context, index) {
        final code = linkedCodes[index];
        return QrLinkedCodeTile(
          code: code,
          enabled: !isLoading,
          onTap: () => onPreviewPressed(code),
          onRenamePressed: () => onRenamePressed(code),
          onDeletePressed: () => onDeletePressed(code),
        );
      },
    );
  }
}

class _QrLinkedCodesEmptyState extends StatelessWidget {
  const _QrLinkedCodesEmptyState({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PauzaSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: PauzaSpacing.small,
          children: [
            Text(
              context.l10n.qrCodeConfigNoCodesTitle,
              style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              isLoading ? context.l10n.loadingLabel : context.l10n.qrCodeConfigNoCodesBody,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge?.copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
