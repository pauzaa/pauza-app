import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/modes/common/model/mode_icon.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

final class ModeIconPickerSheet extends StatelessWidget {
  const ModeIconPickerSheet({required this.title, required this.subtitle, required this.selectedIcon, super.key});

  final String title;
  final String subtitle;
  final ModeIcon selectedIcon;

  static Future<ModeIcon?> show(BuildContext context, {required String title, required String subtitle, required ModeIcon selectedIcon}) {
    return showModalBottomSheet<ModeIcon>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => ModeIconPickerSheet(title: title, subtitle: subtitle, selectedIcon: selectedIcon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9),
      child: BottomSheetScaffold(
        title: Text(title),
        bodyPadding: const EdgeInsets.symmetric(horizontal: PauzaSpacing.medium, vertical: PauzaSpacing.small),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(subtitle, style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant)),
            const SizedBox(height: PauzaSpacing.medium),
            Expanded(
              child: GridView.builder(
                itemCount: ModeIconCatalog.entries.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: PauzaSpacing.medium,
                  mainAxisSpacing: PauzaSpacing.medium,
                ),
                itemBuilder: (context, index) {
                  final entry = ModeIconCatalog.entries[index];
                  final isSelected = entry == selectedIcon;
                  final borderColor = isSelected ? context.colorScheme.primary : context.colorScheme.outlineVariant;
                  final foregroundColor = isSelected ? context.colorScheme.primary : context.colorScheme.onSurfaceVariant;
                  return Material(
                    color: context.colorScheme.surfaceContainerLowest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(PauzaCornerRadius.medium),
                      side: BorderSide(color: borderColor, width: isSelected ? 1.6 : 1),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(PauzaCornerRadius.medium),
                      onTap: () => Navigator.of(context).pop(entry),
                      child: Padding(
                        padding: const EdgeInsets.all(PauzaSpacing.small),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: PauzaSpacing.small,
                          children: <Widget>[
                            Icon(entry.icon, color: foregroundColor, size: PauzaIconSizes.medium),
                            Text(
                              entry.localizedLabel(context.l10n),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.labelMedium?.copyWith(
                                color: foregroundColor,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
