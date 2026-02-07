import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_screen.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza/src/features/home/bloc/blocking_bloc.dart';
import 'package:pauza/src/features/modes/list/bloc/modes_bloc.dart';
import 'package:pauza/src/features/modes/common/model/mode_summary.dart';
import 'package:pauza/src/features/modes/list/widget/confirm_delete_mode_dialog.dart';

class ModePickerSheet extends StatefulWidget {
  const ModePickerSheet({super.key});

  static void show(BuildContext context) {
    HelmRouter.push(context, PauzaRoutes.modePicker);
  }

  static void close(BuildContext context) {
    HelmRouter.pop(context);
  }

  @override
  State<ModePickerSheet> createState() => _ModePickerSheetState();
}

class _ModePickerSheetState extends State<ModePickerSheet> {
  @override
  void initState() {
    super.initState();
    // Reload modes when sheet opens
    context.read<ModesListBloc>().add(const ModesListRequested());
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BottomSheetScaffold(
      title: Text('Select Mode', style: textTheme.headlineSmall),
      onClose: () => ModePickerSheet.close(context),
      maxHeight: 560,
      body: BlocBuilder<ModesListBloc, ModesListState>(
        builder: (context, modesState) {
          if (modesState.isLoading) {
            return const Center(
              child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()),
            );
          }

          if (modesState.hasError) {
            final colorScheme = Theme.of(context).colorScheme;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Error: ${modesState.error}',
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (modesState.items.isEmpty) {
            final colorScheme = Theme.of(context).colorScheme;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No modes available.\nCreate your first mode!',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ),
            );
          }

          return BlocBuilder<BlockingBloc, BlockingState>(
            builder: (context, blockingState) {
              return ListView.builder(
                itemCount: modesState.items.length,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                itemBuilder: (context, index) {
                  final summary = modesState.items[index];
                  final isActive = blockingState.activeModeId == summary.mode.id;
                  final isSelected = modesState.selectedMode?.mode.id == summary.mode.id;

                  return _ModeListItem(
                    summary: summary,
                    isActive: isActive,
                    isSelected: isSelected,
                    onTap: () => _onModeTap(context, summary),
                    onEdit: () => _onEditMode(context, summary),
                    onDelete: () => _onDeleteMode(context, summary),
                  );
                },
              );
            },
          );
        },
      ),
      footer: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () => _onAddNewMode(context),
          icon: const Icon(Icons.add),
          label: const Text('Add New Mode'),
        ),
      ),
    );
  }

  void _onModeTap(BuildContext context, ModeSummary summary) {
    if (!summary.mode.isEnabled) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('This mode is disabled')));
      return;
    }

    context.read<ModesListBloc>().add(ModesSelectionRequested(modeId: summary.mode.id));
    ModePickerSheet.close(context);
  }

  void _onEditMode(BuildContext context, ModeSummary summary) {
    ModeEditorScreen.show(context, modeId: summary.mode.id);
  }

  void _onDeleteMode(BuildContext context, ModeSummary summary) {
    ConfirmDeleteModeDialog.show(context, modeId: summary.mode.id);
  }

  void _onAddNewMode(BuildContext context) {
    ModeEditorScreen.show(context);
  }
}

class _ModeListItem extends StatelessWidget {
  const _ModeListItem({
    required this.summary,
    required this.isActive,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final ModeSummary summary;
  final bool isActive;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final tone = _ModeItemTone.resolve(
      colorScheme: colorScheme,
      isActive: isActive,
      isSelected: isSelected,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: tone.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tone.borderColor),
      ),
      child: Material(
        color: colorScheme.surface.withValues(alpha: 0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              summary.mode.title,
                              style: textTheme.titleMedium?.copyWith(color: tone.titleColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isActive || isSelected) ...[
                            const SizedBox(width: 8),
                            _StatusBadge(
                              title: isActive ? 'Active' : 'Selected',
                              backgroundColor: tone.badgeBackgroundColor,
                              foregroundColor: tone.badgeForegroundColor,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${summary.blockedAppsCount} ${summary.blockedAppsCount == 1 ? 'app' : 'apps'} blocked',
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit mode',
                  color: colorScheme.primary,
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete mode',
                  color: colorScheme.error,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.title,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String title;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          title,
          style: textTheme.labelSmall?.copyWith(
            color: foregroundColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

final class _ModeItemTone {
  const _ModeItemTone({
    required this.backgroundColor,
    required this.borderColor,
    required this.titleColor,
    required this.badgeBackgroundColor,
    required this.badgeForegroundColor,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color titleColor;
  final Color badgeBackgroundColor;
  final Color badgeForegroundColor;

  static _ModeItemTone resolve({
    required ColorScheme colorScheme,
    required bool isActive,
    required bool isSelected,
  }) {
    if (isActive) {
      return _ModeItemTone(
        backgroundColor: colorScheme.secondaryContainer,
        borderColor: colorScheme.secondary,
        titleColor: colorScheme.onSecondaryContainer,
        badgeBackgroundColor: colorScheme.secondary,
        badgeForegroundColor: colorScheme.onSecondary,
      );
    }

    if (isSelected) {
      return _ModeItemTone(
        backgroundColor: colorScheme.primaryContainer,
        borderColor: colorScheme.primary,
        titleColor: colorScheme.onPrimaryContainer,
        badgeBackgroundColor: colorScheme.primary,
        badgeForegroundColor: colorScheme.onPrimary,
      );
    }

    return _ModeItemTone(
      backgroundColor: colorScheme.surfaceContainerLow,
      borderColor: colorScheme.outlineVariant,
      titleColor: colorScheme.onSurface,
      badgeBackgroundColor: colorScheme.surface,
      badgeForegroundColor: colorScheme.onSurface,
    );
  }
}
