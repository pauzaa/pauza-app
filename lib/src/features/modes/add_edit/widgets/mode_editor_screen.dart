import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/core/common/root_scope.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.dart';
import 'package:pauza/src/features/modes/add_edit/bloc/installed_apps_bloc.dart';
import 'package:pauza/src/features/modes/add_edit/bloc/mode_editor_bloc.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/android_apps_bottom_sheet.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_upsert_draft_notifier.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza/src/features/modes/list/bloc/modes_bloc.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class ModeEditorScreen extends StatelessWidget {
  const ModeEditorScreen({required this.modeId, super.key});

  factory ModeEditorScreen.create() => const ModeEditorScreen(modeId: null);

  factory ModeEditorScreen.edit({required String modeId}) => ModeEditorScreen(modeId: modeId);

  static void show(BuildContext context, {String? modeId}) {
    if (modeId == null) {
      HelmRouter.push(context, PauzaRoutes.modeCreate);
    } else {
      HelmRouter.push(
        context,
        PauzaRoutes.modeEdit,
        pathParams: <String, String>{'midEdit': modeId},
      );
    }
  }

  final String? modeId;

  @override
  Widget build(BuildContext context) {
    final rootScope = RootScope.of(context);
    return BlocProvider(
      create: (context) => ModeEditorBloc(modesRepository: rootScope.modesRepository),
      child: ModeEditorMainScreen(modeId: modeId),
    );
  }
}

class ModeEditorMainScreen extends StatefulWidget {
  const ModeEditorMainScreen({required this.modeId, super.key});

  final String? modeId;

  @override
  State<ModeEditorMainScreen> createState() => _ModeEditorMainScreenState();
}

class _ModeEditorMainScreenState extends State<ModeEditorMainScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ModeUpsertDraftNotifier _draftNotifier = ModeUpsertDraftNotifier();

  PauzaPlatform get _platform => PauzaPlatform.current;
  bool get _isEditMode => widget.modeId != null;

  @override
  void initState() {
    super.initState();
    context.read<ModeEditorBloc>().add(ModeEditorLoadRequested(modeId: widget.modeId));
  }

  @override
  void dispose() {
    _draftNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ModeUpsertScope(
      notifier: _draftNotifier,
      child: BlocListener<ModeEditorBloc, ModeEditorState>(
        listener: (context, state) {
          switch (state) {
            case ModeEditorInitial():
            case ModeEditorLoading():
              break;
            case ModeEditorReady(request: final request):
              _draftNotifier.replace(request);
              break;
            case ModeEditorSaveSuccess():
              context.read<ModesListBloc>().add(const ModesListRequested());
              Navigator.of(context).pop();
              break;
            case ModeEditorFailure():
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(l10n.modeSaveFailedMessage)));
              break;
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(_isEditMode ? l10n.editModeTitle : l10n.createModeTitle),
            actions: [
              BlocSelector<ModeEditorBloc, ModeEditorState, bool>(
                selector: (state) => state is ModeEditorLoading,
                builder: (context, isSaving) => PauzaIconButton(
                  onPressed: isSaving ? null : () => _onSavePressed(context),
                  icon: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                ),
              ),
            ],
          ),
          body: BlocBuilder<ModeEditorBloc, ModeEditorState>(
            builder: (context, state) {
              if (state case ModeEditorInitial() || ModeEditorLoading()) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state case final ModeEditorFailure failureState) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${l10n.modeLoadFailedMessage}\n${failureState.error}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ModeEditorBloc>().add(
                              ModeEditorLoadRequested(modeId: widget.modeId),
                            );
                          },
                          child: Text(l10n.retryButton),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final draftNotifier = ModeUpsertScope.watch(context);
              final draft = draftNotifier.value;

              return Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(PauzaSpacing.medium),
                  children: [
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PauzaTextFormField(
                            key: ValueKey<String>('title-${draftNotifier.revision}'),
                            initialValue: draft.title,
                            decoration: PauzaInputDecoration(labelText: l10n.modeTitleFieldLabel),
                            textInputAction: TextInputAction.next,
                            onChanged: (value) =>
                                draftNotifier.update((dto) => dto.copyWith(title: value)),
                            validator: (value) => (value == null || value.trim().isEmpty)
                                ? l10n.modeRequiredFieldError
                                : null,
                          ),
                          const SizedBox(height: PauzaSpacing.medium),
                          PauzaTextFormField(
                            key: ValueKey<String>('text-on-screen-${draftNotifier.revision}'),
                            initialValue: draft.textOnScreen,
                            decoration: PauzaInputDecoration(
                              labelText: l10n.modeTextOnScreenFieldLabel,
                            ),
                            textInputAction: TextInputAction.next,
                            onChanged: (value) =>
                                draftNotifier.update((dto) => dto.copyWith(textOnScreen: value)),
                            validator: (value) =>
                                (draftNotifier.value.textOnScreen.isEmpty ||
                                    value == null ||
                                    value.trim().isEmpty)
                                ? l10n.modeRequiredFieldError
                                : null,
                          ),
                          const SizedBox(height: PauzaSpacing.medium),
                          PauzaTextFormField(
                            key: ValueKey<String>('allowed-pauses-${draftNotifier.revision}'),
                            initialValue: draft.allowedPausesCount.toString(),
                            keyboardType: TextInputType.number,
                            decoration: const PauzaInputDecoration(
                              labelText: 'Allowed pauses count',
                            ),
                            onChanged: (value) {
                              final parsed = int.tryParse(value.trim());
                              if (parsed case final pausesCount? when pausesCount >= 0) {
                                draftNotifier.update(
                                  (dto) => dto.copyWith(allowedPausesCount: pausesCount),
                                );
                              }
                            },
                            validator: (value) {
                              if (draftNotifier.value.allowedPausesCount == 0 ||
                                  value == null ||
                                  value.trim().isEmpty) {
                                return l10n.modeRequiredFieldError;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: PauzaSpacing.regular),
                          PauzaSwitch(
                            value: draft.isEnabled,
                            onChanged: (value) =>
                                draftNotifier.update((dto) => dto.copyWith(isEnabled: value)),
                            label: l10n.modeEnabledLabel,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: PauzaSpacing.large),
                    _SectionCard(
                      child: FormField<ISet<String>>(
                        key: ValueKey<String>('blocked-apps-${draftNotifier.revision}'),
                        initialValue: draft.blockedAppIds,
                        validator: (value) => (value == null || value.isEmpty)
                            ? l10n.modeBlockedAppsRequiredError
                            : null,
                        builder: (field) {
                          final selectedAppIds =
                              (field.value ?? const ISetConst(<String>{})).unlock;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    l10n.modeBlockedAppsSectionTitle,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: context.colorScheme.primary,
                                    ),
                                  ),
                                  PauzaTextButton(
                                    title: Text(l10n.modeBlockedAppsChooseButton),
                                    onPressed: () => _onChooseAppsPressed(
                                      currentSelection: selectedAppIds,
                                      onChanged: (selectedIds) {
                                        draftNotifier.update(
                                          (dto) => dto.copyWith(blockedAppIds: selectedIds),
                                        );
                                        field.didChange(selectedIds);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: PauzaSpacing.small),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: PauzaSpacing.regular,
                                  vertical: PauzaSpacing.small,
                                ),
                                decoration: BoxDecoration(
                                  color: context.colorScheme.primaryContainer.withValues(
                                    alpha: 0.3,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.apps, size: 16, color: context.colorScheme.primary),
                                    const SizedBox(width: PauzaSpacing.small),
                                    Text(
                                      l10n.modeBlockedAppsSelectedCountLabel(selectedAppIds.length),
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: context.colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (field.hasError) ...[
                                const SizedBox(height: PauzaSpacing.small),
                                Text(
                                  field.errorText ?? '',
                                  style: TextStyle(color: context.colorScheme.error),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: PauzaSpacing.large),
                    PauzaFilledButton(
                      title: Text(_isEditMode ? l10n.editModeButton : l10n.createModeTitle),
                      onPressed: () => _onSavePressed(context),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _onChooseAppsPressed({
    required Set<String> currentSelection,
    required ValueChanged<ISet<String>> onChanged,
  }) async {
    final l10n = AppLocalizations.of(context);
    final rootScope = RootScope.of(context);

    try {
      if (_platform == PauzaPlatform.android) {
        final selectedIds = await showModalBottomSheet<Set<String>>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          showDragHandle: true,
          builder: (_) {
            return BlocProvider(
              create: (_) => InstalledAppsBloc(
                installedAppsRepository: rootScope.installedAppsRepository,
              )..add(const InstalledAppsRequested(includeIcons: false, includeSystemApps: true)),
              child: AndroidAppsBottomSheet(initialSelectedAppIds: currentSelection),
            );
          },
        );
        if (!mounted || selectedIds == null) {
          return;
        }
        onChanged(selectedIds.toISet());
        return;
      }

      final preSelectedApps = currentSelection
          .map((token) => IOSAppInfo(applicationToken: token))
          .toList(growable: false);
      final selectedApps = await rootScope.installedAppsRepository.selectIOSApps(
        preSelectedApps: preSelectedApps,
      );
      if (!mounted) {
        return;
      }
      onChanged(selectedApps.map((app) => app.identifier).toISet());
    } on Object {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.modeAppsLoadFailedMessage)));
    }
  }

  void _onSavePressed(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final draft = _draftNotifier.value;
    final normalizedRequest = draft.copyWith(
      title: draft.title.trim(),
      textOnScreen: draft.textOnScreen.trim(),
      description: draft.description?.trim().isEmpty ?? true ? null : draft.description?.trim(),
    );
    _draftNotifier.update((_) => normalizedRequest);
    context.read<ModeEditorBloc>().add(
      ModeEditorSaveRequested(modeId: widget.modeId, request: normalizedRequest),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PauzaSpacing.medium),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: child,
    );
  }
}
