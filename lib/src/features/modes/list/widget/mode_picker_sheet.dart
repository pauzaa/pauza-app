import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
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
    context.read<ModesListBloc>().add(ModesListRequested(platform: PauzaPlatform.current));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Mode',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => ModePickerSheet.close(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Modes list
            Flexible(
              child: BlocBuilder<ModesListBloc, ModesListState>(
                builder: (context, modesState) {
                  return BlocBuilder<BlockingBloc, BlockingState>(
                    builder: (context, blockingState) {
                      if (modesState.isLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (modesState.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              'Error: ${modesState.error}',
                              style: TextStyle(color: Colors.red[700]),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      if (modesState.items.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text(
                              'No modes available.\nCreate your first mode!',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: modesState.items.length,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemBuilder: (context, index) {
                          final summary = modesState.items[index];
                          final isActive = blockingState.activeModeId == summary.mode.id;

                          return _ModeListItem(
                            summary: summary,
                            isActive: isActive,
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
            ),

            // Add new mode button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _onAddNewMode(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Mode'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
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

    context.read<BlockingBloc>().add(
      BlockingStartRequested(modeId: summary.mode.id, platform: PauzaPlatform.current),
    );
    ModePickerSheet.close(context);
  }

  void _onEditMode(BuildContext context, ModeSummary summary) {
    // TODO: Navigate to mode editor (not in scope)
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Edit mode - not yet implemented')));
  }

  void _onDeleteMode(BuildContext context, ModeSummary summary) {
    ConfirmDeleteModeDialog.show(context, modeId: summary.mode.id);
  }

  void _onAddNewMode(BuildContext context) {
    // TODO: Navigate to mode editor (not in scope)
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Add new mode - not yet implemented')));
  }
}

class _ModeListItem extends StatelessWidget {
  const _ModeListItem({
    required this.summary,
    required this.isActive,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final ModeSummary summary;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? Colors.green[300]! : Colors.transparent, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Mode info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            summary.mode.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isActive ? Colors.green[700] : Colors.black87,
                            ),
                          ),
                          if (isActive) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green[700],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Active',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${summary.blockedAppsCount} ${summary.blockedAppsCount == 1 ? 'app' : 'apps'} blocked',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: onEdit,
                      color: Colors.blue[700],
                      tooltip: 'Edit mode',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: onDelete,
                      color: Colors.red[700],
                      tooltip: 'Delete mode',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
