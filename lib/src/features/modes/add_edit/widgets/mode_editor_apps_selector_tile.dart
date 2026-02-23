import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/core/common_ui/pauza_toast.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_card.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_upsert_draft_notifier.dart';
import 'package:pauza/src/features/modes/select_apps/widgets/android_apps_bottom_sheet.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

final class ModeEditorAppsSelectorTile extends StatelessWidget {
  const ModeEditorAppsSelectorTile({
    required this.title,
    required this.subtitle,
    required this.selectedCountLabel,
    required this.enabled,
    super.key,
    this.errorText,
  });

  final String title;
  final String subtitle;
  final String selectedCountLabel;
  final String? errorText;
  final bool enabled;

  Future<void> _onChooseAppsPressed(BuildContext context) async {
    final notifier = ModeUpsertScope.watch(context);
    final currentSelection = notifier.value.blockedAppIds;
    final l10n = AppLocalizations.of(context);
    final rootScope = RootScope.of(context);

    try {
      if (kPauzaPlatform == PauzaPlatform.android) {
        final selectedIds = await AndroidAppsBottomSheet.show(context, initialSelectedAppIds: currentSelection);
        if (!context.mounted || selectedIds == null) {
          return;
        }
        notifier.updateBlockedApps(selectedIds.toISet());
        return;
      }

      final preSelectedApps = currentSelection
          .map((token) => IOSAppInfo(applicationToken: token))
          .toList(growable: false);
      final selectedApps = await rootScope.installedAppsRepository.selectIOSApps(preSelectedApps: preSelectedApps);
      if (!context.mounted) {
        return;
      }
      notifier.updateBlockedApps(selectedApps.map((app) => app.identifier).toISet());
    } on Object {
      if (!context.mounted) {
        return;
      }
      context.showToast(l10n.modeAppsLoadFailedMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    return Column(
      spacing: PauzaSpacing.small,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ModeEditorCard(
          borderColor: hasError ? context.colorScheme.error.withValues(alpha: 0.8) : null,
          child: InkWell(
            onTap: enabled ? () => _onChooseAppsPressed(context) : null,
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
                    child: Icon(Icons.apps, color: context.colorScheme.primary),
                  ),
                ),
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
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(PauzaCornerRadius.full),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: PauzaSpacing.medium, vertical: PauzaSpacing.small),
                    child: Text(
                      selectedCountLabel,
                      style: context.textTheme.labelLarge?.copyWith(
                        color: context.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: context.colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
        if (hasError) Text(errorText!, style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.error)),
      ],
    );
  }
}
