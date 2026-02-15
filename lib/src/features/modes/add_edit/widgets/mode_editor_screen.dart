import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza/src/features/modes/add_edit/bloc/mode_editor_bloc.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_upsert_draft_notifier.dart';
import 'package:pauza/src/features/modes/common/model/week_day.dart';
import 'package:pauza/src/features/modes/list/widget/confirm_delete_mode_dialog.dart';
import 'package:pauza/src/features/modes/select_apps/widgets/android_apps_bottom_sheet.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class ModeEditorScreen extends StatelessWidget {
  const ModeEditorScreen({required this.modeId, super.key});

  factory ModeEditorScreen.create() => const ModeEditorScreen(modeId: null);

  factory ModeEditorScreen.edit({required String modeId}) =>
      ModeEditorScreen(modeId: modeId);

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
      create: (context) =>
          ModeEditorBloc(modesRepository: rootScope.modesRepository),
      child: ModeEditorMainScreen(modeId: modeId),
    );
  }
}

enum _ModeEditorAction { load, save, delete, idle }

class ModeEditorMainScreen extends StatefulWidget {
  const ModeEditorMainScreen({required this.modeId, super.key});

  final String? modeId;

  @override
  State<ModeEditorMainScreen> createState() => _ModeEditorMainScreenState();
}

class _ModeEditorMainScreenState extends State<ModeEditorMainScreen> {
  final ModeUpsertDraftNotifier _draftNotifier = ModeUpsertDraftNotifier();
  _ModeEditorAction _action = _ModeEditorAction.load;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  @override
  void dispose() {
    _draftNotifier.dispose();
    super.dispose();
  }

  void _loadDraft() {
    _action = _ModeEditorAction.load;
    context.read<ModeEditorBloc>().add(
      ModeEditorLoadRequested(modeId: widget.modeId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModeUpsertScope(
      notifier: _draftNotifier,
      child: BlocConsumer<ModeEditorBloc, ModeEditorState>(
        listener: (context, state) {
          if (state is ModeEditorReady) {
            _draftNotifier.configureForMode(
              initialDraft: state.request,
              isEditMode: state.modeId != null,
            );
            if (!_initialized && mounted) {
              setState(() {
                _initialized = true;
              });
            }
            _action = _ModeEditorAction.idle;
          }

          if (state is ModeEditorSaveSuccess ||
              state is ModeEditorDeleteSuccess) {
            if (!mounted) {
              return;
            }
            Navigator.of(context).pop();
            return;
          }

          if (state is ModeEditorFailure && mounted) {
            final l10n = context.l10n;
            final message = switch (_action) {
              _ModeEditorAction.load => l10n.modeLoadFailedMessage,
              _ModeEditorAction.save => l10n.modeSaveFailedMessage,
              _ModeEditorAction.delete => l10n.modeDeleteFailedMessage,
              _ModeEditorAction.idle => l10n.errorTitle,
            };
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
            _action = _ModeEditorAction.idle;
          }
        },
        builder: (context, state) {
          if (!_initialized) {
            return _buildInitialState(context, state);
          }

          final isBusy = state is ModeEditorLoading;
          return _buildEditorScaffold(context, isBusy: isBusy);
        },
      ),
    );
  }

  Widget _buildInitialState(BuildContext context, ModeEditorState state) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.modeId == null ? l10n.createModeTitle : l10n.editModeTitle,
        ),
        leading: TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: Text(l10n.cancelButton),
        ),
      ),
      body: Center(
        child: switch (state) {
          ModeEditorFailure() => Column(
            mainAxisSize: MainAxisSize.min,
            spacing: PauzaSpacing.medium,
            children: <Widget>[
              Text(
                l10n.modeLoadFailedMessage,
                style: context.textTheme.bodyLarge,
              ),
              PauzaOutlinedButton(
                title: Text(l10n.retryButton),
                onPressed: _loadDraft,
              ),
            ],
          ),
          _ => const CircularProgressIndicator(),
        },
      ),
    );
  }

  Widget _buildEditorScaffold(BuildContext context, {required bool isBusy}) {
    final l10n = context.l10n;
    final draftNotifier = ModeUpsertScope.watch(context);
    final draft = draftNotifier.value;
    final validation = draftNotifier.validation;
    final schedule = draft.schedule;
    final isScheduleEnabled = schedule?.enabled ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.modeId == null ? l10n.createModeTitle : l10n.editModeTitle,
        ),
        leading: TextButton(
          onPressed: isBusy ? null : () => Navigator.of(context).maybePop(),
          child: Text(l10n.cancelButton),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                PauzaSpacing.medium,
                PauzaSpacing.medium,
                PauzaSpacing.medium,
                PauzaSpacing.large,
              ),
              children: <Widget>[
                ModeEditorSectionLabel(label: l10n.modeTitleFieldLabel),
                PauzaTextFormField(
                  key: ValueKey<int>(draftNotifier.revision),
                  initialValue: draft.title,
                  onChanged: _draftNotifier.updateTitle,
                  decoration: PauzaInputDecoration(
                    hintText: l10n.modeTitleFieldLabel,
                    errorText: _errorForField(
                      context,
                      validation[ModeUpsertValidationField.title],
                    ),
                  ),
                ),
                const SizedBox(height: PauzaSpacing.large),
                ModeEditorSectionLabel(label: l10n.modeTextOnScreenFieldLabel),
                PauzaTextFormField(
                  initialValue: draft.textOnScreen,
                  onChanged: _draftNotifier.updateTextOnScreen,
                  decoration: PauzaInputDecoration(
                    hintText: l10n.modeTextOnScreenFieldLabel,
                    errorText: _errorForField(
                      context,
                      validation[ModeUpsertValidationField.textOnScreen],
                    ),
                  ),
                ),
                const SizedBox(height: PauzaSpacing.large),
                ModeEditorSectionLabel(label: l10n.modeDescriptionFieldLabel),
                PauzaTextFormField(
                  initialValue: draft.description ?? '',
                  onChanged: _draftNotifier.updateDescription,
                  maxLines: 3,
                  decoration: PauzaInputDecoration(
                    hintText: l10n.modeDescriptionFieldLabel,
                  ),
                ),
                const SizedBox(height: PauzaSpacing.large),
                ModeEditorSectionLabel(label: l10n.modeBlockedAppsSectionTitle),
                ModeEditorAppsSelectorTile(
                  title: l10n.modeBlockedAppsChooseButton,
                  subtitle: l10n.modeBlockedAppsSubtitle,
                  selectedCountLabel: l10n.modeBlockedAppsSelectedCountLabel(
                    draft.blockedAppIds.length,
                  ),
                  errorText: _errorForField(
                    context,
                    validation[ModeUpsertValidationField.blockedApps],
                  ),
                  onTap: isBusy
                      ? () {}
                      : () {
                          onChooseAppsPressed(
                            currentSelection: draft.blockedAppIds.toSet(),
                            onChanged: _draftNotifier.updateBlockedApps,
                          );
                        },
                ),
                const SizedBox(height: PauzaSpacing.large),
                ModeEditorSchedulePanel(
                  title: l10n.modeScheduleTitle,
                  enabled: isScheduleEnabled,
                  onToggle: isBusy
                      ? (_) {}
                      : _draftNotifier.toggleScheduleEnabled,
                  days: WeekDay.values
                      .map(
                        (day) => ModeEditorDayChipItem(
                          id: day.name,
                          label: _dayLabel(day),
                          isSelected: schedule?.days.contains(day) ?? false,
                        ),
                      )
                      .toList(growable: false),
                  onDayPressed: isBusy
                      ? (_) {}
                      : (dayName) {
                          _draftNotifier.toggleScheduleDay(
                            WeekDay.values.firstWhere(
                              (day) => day.name == dayName,
                            ),
                          );
                        },
                  startTitle: l10n.modeScheduleStartTimeLabel,
                  endTitle: l10n.modeScheduleEndTimeLabel,
                  startValue: _formatTime(context, schedule?.start),
                  endValue: _formatTime(context, schedule?.end),
                  onStartPressed: isBusy
                      ? () {}
                      : () => _onPickStartTime(context, schedule?.start),
                  onEndPressed: isBusy
                      ? () {}
                      : () => _onPickEndTime(context, schedule?.end),
                  errorText: _errorForField(
                    context,
                    validation[ModeUpsertValidationField.scheduleDays],
                  ),
                ),
                const SizedBox(height: PauzaSpacing.large),
                ModeEditorSectionLabel(label: l10n.modeStrictnessTitle),
                ModeEditorAllowedPausesTile(
                  title: l10n.modeAllowedPausesTitle,
                  subtitle: l10n.modeAllowedPausesSubtitle,
                  value: draft.allowedPausesCount,
                  canIncrement:
                      draft.allowedPausesCount <
                      ModeUpsertDraftNotifier.maxAllowedPauses,
                  canDecrement:
                      draft.allowedPausesCount >
                      ModeUpsertDraftNotifier.minAllowedPauses,
                  onIncrement: isBusy ? null : _draftNotifier.incrementPauses,
                  onDecrement: isBusy ? null : _draftNotifier.decrementPauses,
                ),
                if (widget.modeId != null) ...<Widget>[
                  const SizedBox(height: PauzaSpacing.extraLarge),
                  Center(
                    child: TextButton(
                      onPressed: isBusy ? null : _onDeletePressed,
                      child: Text(
                        l10n.modeDeleteFocusButton,
                        style: context.textTheme.titleLarge?.copyWith(
                          color: context.colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          ModeEditorStickyActionBar(
            buttonLabel: l10n.modeSaveButton,
            isBusy: isBusy && _action == _ModeEditorAction.save,
            onPressed: isBusy ? null : () => _onSavePressed(context),
          ),
        ],
      ),
    );
  }

  String _dayLabel(WeekDay day) {
    final value = day.localizeShort(context.l10n);
    if (value.isEmpty) {
      return '';
    }
    return value.substring(0, 1).toUpperCase();
  }

  String _formatTime(BuildContext context, TimeOfDay? time) {
    final resolvedTime = time ?? const TimeOfDay(hour: 9, minute: 0);
    return MaterialLocalizations.of(context).formatTimeOfDay(resolvedTime);
  }

  Future<void> _onPickStartTime(
    BuildContext context,
    TimeOfDay? initial,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initial ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (!mounted || picked == null) {
      return;
    }
    _draftNotifier.updateScheduleStart(picked);
  }

  Future<void> _onPickEndTime(BuildContext context, TimeOfDay? initial) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initial ?? const TimeOfDay(hour: 17, minute: 0),
    );
    if (!mounted || picked == null) {
      return;
    }
    _draftNotifier.updateScheduleEnd(picked);
  }

  Future<void> onChooseAppsPressed({
    required Set<AppIdentifier> currentSelection,
    required ValueChanged<Set<AppIdentifier>> onChanged,
  }) async {
    final l10n = AppLocalizations.of(context);
    final rootScope = RootScope.of(context);

    try {
      if (kPauzaPlatform == PauzaPlatform.android) {
        final selectedIds = await showModalBottomSheet<Set<AppIdentifier>>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          showDragHandle: true,
          builder: (_) {
            return AndroidAppsBottomSheet(
              initialSelectedAppIds: currentSelection,
            );
          },
        );
        if (!mounted || selectedIds == null) {
          return;
        }
        onChanged(selectedIds);
        return;
      }

      final preSelectedApps = currentSelection
          .map((token) => IOSAppInfo(applicationToken: token))
          .toList(growable: false);
      final selectedApps = await rootScope.installedAppsRepository
          .selectIOSApps(preSelectedApps: preSelectedApps);
      if (!mounted) {
        return;
      }
      onChanged(selectedApps.map((app) => app.identifier).toSet());
    } on Object {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.modeAppsLoadFailedMessage)));
    }
  }

  Future<void> _onDeletePressed() async {
    final shouldDelete = await ConfirmDeleteModeDialog.show(context);
    if (!mounted || shouldDelete != true) {
      return;
    }

    _action = _ModeEditorAction.delete;
    context.read<ModeEditorBloc>().add(
      ModeEditorDeleteRequested(modeId: widget.modeId),
    );
  }

  void _onSavePressed(BuildContext context) {
    final validation = _draftNotifier.validateForSubmit();
    if (!validation.isValid) {
      return;
    }

    _action = _ModeEditorAction.save;
    context.read<ModeEditorBloc>().add(
      ModeEditorSaveRequested(
        modeId: widget.modeId,
        request: _draftNotifier.buildSubmitRequest(),
      ),
    );
  }

  String? _errorForField(
    BuildContext context,
    ModeUpsertValidationCode? error,
  ) {
    if (error == null) {
      return null;
    }
    final l10n = context.l10n;
    return switch (error) {
      ModeUpsertValidationCode.required => l10n.modeRequiredFieldError,
      ModeUpsertValidationCode.blockedAppsRequired =>
        l10n.modeBlockedAppsRequiredError,
      ModeUpsertValidationCode.allowedPausesOutOfRange =>
        l10n.modeAllowedPausesOutOfRangeError(
          ModeUpsertDraftNotifier.minAllowedPauses,
          ModeUpsertDraftNotifier.maxAllowedPauses,
        ),
      ModeUpsertValidationCode.scheduleDaysRequired =>
        l10n.modeScheduleDaysRequiredError,
    };
  }
}
