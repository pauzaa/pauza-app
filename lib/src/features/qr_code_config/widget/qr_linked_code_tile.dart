import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/qr_code_config/model/qr_linked_code.dart';
import 'package:pauza/src/features/qr_code_config/widget/qr_linked_code_menu.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class QrLinkedCodeTile extends StatelessWidget {
  const QrLinkedCodeTile({
    required this.code,
    required this.enabled,
    required this.onTap,
    required this.onRenamePressed,
    required this.onDeletePressed,
    super.key,
  });

  final QrLinkedCode code;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onRenamePressed;
  final VoidCallback onDeletePressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Material(
      color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.75)),
      ),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: PauzaSpacing.medium, vertical: PauzaSpacing.regular),
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
                      code.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      context.l10n.qrCodeConfigLinkedOnDate(code.createdAt.formatLinkedDate(context)),
                      style: context.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              QrLinkedCodeMenu(enabled: enabled, onRenamePressed: onRenamePressed, onDeletePressed: onDeletePressed),
            ],
          ),
        ),
      ),
    );
  }
}
