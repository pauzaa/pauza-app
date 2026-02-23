import 'package:flutter/material.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_card.dart';
import 'package:pauza/src/features/modes/common/model/mode_ending_pausing_scenario.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

final class ModeEditorEndingPausingScenarioPanel extends StatelessWidget {
  const ModeEditorEndingPausingScenarioPanel({
    required this.title,
    required this.subtitle,
    required this.nfcLabel,
    required this.qrLabel,
    required this.manualLabel,
    required this.selectedScenario,
    required this.onScenarioPressed,
    super.key,
    this.nfcDisabled = false,
    this.nfcDisabledHint,
  });

  final String title;
  final String subtitle;
  final String nfcLabel;
  final String qrLabel;
  final String manualLabel;
  final ModeEndingPausingScenario selectedScenario;
  final ValueChanged<ModeEndingPausingScenario> onScenarioPressed;
  final bool nfcDisabled;
  final String? nfcDisabledHint;

  @override
  Widget build(BuildContext context) {
    return ModeEditorCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: PauzaSpacing.medium,
        children: <Widget>[
          Text(title, style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          Text(subtitle, style: context.textTheme.bodyLarge?.copyWith(color: context.colorScheme.onSurfaceVariant)),
          Row(
            spacing: PauzaSpacing.small,
            children: <Widget>[
              Expanded(
                child: _ScenarioButton(
                  label: nfcLabel,
                  isSelected: selectedScenario == ModeEndingPausingScenario.nfc,
                  disabled: nfcDisabled,
                  onPressed: () => onScenarioPressed(ModeEndingPausingScenario.nfc),
                ),
              ),
              Expanded(
                child: _ScenarioButton(
                  label: qrLabel,
                  isSelected: selectedScenario == ModeEndingPausingScenario.qrCode,
                  onPressed: () => onScenarioPressed(ModeEndingPausingScenario.qrCode),
                ),
              ),
              Expanded(
                child: _ScenarioButton(
                  label: manualLabel,
                  isSelected: selectedScenario == ModeEndingPausingScenario.manual,
                  onPressed: () => onScenarioPressed(ModeEndingPausingScenario.manual),
                ),
              ),
            ],
          ),
          if (nfcDisabled && nfcDisabledHint != null)
            Text(
              nfcDisabledHint!,
              style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}

final class _ScenarioButton extends StatelessWidget {
  const _ScenarioButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
    this.disabled = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return PauzaOutlinedButton(
      size: PauzaButtonSize.small,
      title: Text(label, textAlign: TextAlign.center),
      onPressed: onPressed,
      selected: isSelected,
      disabled: disabled,
    );
  }
}
