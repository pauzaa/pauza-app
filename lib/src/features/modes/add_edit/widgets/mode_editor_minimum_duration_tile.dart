import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_card.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_upsert_draft_notifier.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

final class ModeEditorMinimumDurationTile extends StatelessWidget {
  const ModeEditorMinimumDurationTile({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.actionLabel,
    required this.enabled,
    super.key,
    this.clearLabel,
  });

  final String title;
  final String subtitle;
  final Duration? duration;
  final String actionLabel;
  final String? clearLabel;
  final bool enabled;

  String _formatMinimumDuration(BuildContext context, Duration? duration) {
    if (duration == null) {
      return context.l10n.modeMinimumDurationNotSet;
    }
    return context.l10n.modeMinimumDurationValueMinutes(duration.inMinutes);
  }

  Future<void> _onPickMinimumDuration(BuildContext context) async {
    final draftNotifier = ModeUpsertScope.watch(context);
    final picked = await _showMinimumDurationBottomSheet(context: context, initialDuration: duration);
    if (!context.mounted || picked == null) {
      return;
    }

    draftNotifier.updateMinimumDuration(picked);
  }

  Future<Duration?> _showMinimumDurationBottomSheet({
    required BuildContext context,
    required Duration? initialDuration,
  }) {
    const minimum = Duration(minutes: 1);
    const maximum = Duration(hours: 24);
    final defaultDuration = initialDuration ?? const Duration(minutes: 30);

    Duration clamp(Duration value) {
      if (value < minimum) {
        return minimum;
      }
      if (value > maximum) {
        return maximum;
      }
      return value;
    }

    var selectedDuration = clamp(defaultDuration);

    return showModalBottomSheet<Duration?>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: 360,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: PauzaSpacing.medium),
                child: Row(
                  children: <Widget>[
                    PauzaTextButton(
                      size: PauzaButtonSize.small,
                      onPressed: Navigator.of(context).pop,
                      title: Text(context.l10n.modeMinimumDurationClearButton),
                    ),
                    const Spacer(),
                    PauzaFilledButton(
                      size: PauzaButtonSize.small,
                      onPressed: () => Navigator.of(context).pop(selectedDuration),
                      title: Text(context.l10n.doneButton),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hm,
                  initialTimerDuration: selectedDuration,
                  onTimerDurationChanged: (value) {
                    selectedDuration = clamp(value);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModeEditorCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: PauzaSpacing.medium,
        children: <Widget>[
          Row(
            spacing: PauzaSpacing.regular,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: PauzaSpacing.small,
                  children: <Widget>[
                    Text(title, style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    Text(
                      subtitle,
                      style: context.textTheme.bodyLarge?.copyWith(color: context.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Text(
                _formatMinimumDuration(context, duration),
                style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Row(
            spacing: PauzaSpacing.small,
            children: <Widget>[
              if (clearLabel != null && duration != null)
                Expanded(
                  child: PauzaTextButton(
                    size: PauzaButtonSize.small,
                    disabled: !enabled,
                    title: Text(clearLabel ?? context.l10n.modeMinimumDurationClearButton),
                    onPressed: () => ModeUpsertScope.watch(context).updateMinimumDuration(null),
                  ),
                ),
              Expanded(
                child: PauzaOutlinedButton(
                  size: PauzaButtonSize.small,
                  disabled: !enabled,
                  title: Text(actionLabel),
                  onPressed: () => _onPickMinimumDuration(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
