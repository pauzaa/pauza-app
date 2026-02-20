import 'package:flutter/material.dart';
import 'package:pauza/src/features/modes/common/model/mode_icon.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

final class ModeEditorIconPicker extends StatelessWidget {
  const ModeEditorIconPicker({
    required this.selectedIcon,
    required this.onTap,
    super.key,
  });

  final ModeIcon selectedIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(PauzaCornerRadius.medium),
        ),
        child: SizedBox(
          width: PauzaFormSizes.xSmall,
          height: PauzaFormSizes.xSmall,
          child: Icon(selectedIcon.icon, color: context.colorScheme.primary),
        ),
      ),
    );
  }
}
