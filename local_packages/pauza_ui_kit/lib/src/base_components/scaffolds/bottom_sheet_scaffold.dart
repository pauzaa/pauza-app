import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/src/foundations/spacing.dart';

/// Shared shell for app bottom sheets with a consistent header and footer.
final class BottomSheetScaffold extends StatelessWidget {
  const BottomSheetScaffold({
    required this.body,
    this.title,
    super.key,
    this.footer,
    this.onClose,
    this.showDivider = true,
    this.maxHeight,
    this.maxHeightFactor = 0.85,
    this.headerPadding = const EdgeInsets.fromLTRB(PauzaSpacing.medium, PauzaSpacing.regular, PauzaSpacing.small, PauzaSpacing.medium),
    this.bodyPadding = EdgeInsets.zero,
    this.footerPadding = const EdgeInsets.fromLTRB(PauzaSpacing.medium, PauzaSpacing.medium, PauzaSpacing.medium, PauzaSpacing.medium),
  });

  final Widget? title;
  final Widget body;
  final Widget? footer;
  final VoidCallback? onClose;
  final bool showDivider;
  final double? maxHeight;
  final double maxHeightFactor;
  final EdgeInsetsGeometry headerPadding;
  final EdgeInsetsGeometry bodyPadding;
  final EdgeInsetsGeometry footerPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final boundedMaxHeight = maxHeight != null
            ? maxHeight!.clamp(0, constraints.maxHeight).toDouble()
            : constraints.maxHeight * maxHeightFactor;

        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: boundedMaxHeight, minWidth: double.infinity),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title case final title?) ...[
                  Padding(
                    padding: headerPadding,
                    child: Row(
                      children: [
                        Expanded(
                          child: DefaultTextStyle(
                            style: textTheme.headlineSmall ?? textTheme.titleLarge ?? DefaultTextStyle.of(context).style,
                            child: title,
                          ),
                        ),
                        if (onClose != null) IconButton(onPressed: onClose, icon: const Icon(Icons.close), tooltip: 'Close'),
                      ],
                    ),
                  ),
                  if (showDivider) Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.8), height: 1),
                ],
                Flexible(
                  child: Padding(padding: bodyPadding, child: body),
                ),
                if (footer != null) Padding(padding: footerPadding, child: footer),
              ],
            ),
          ),
        );
      },
    );
  }
}
