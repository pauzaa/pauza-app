import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza/src/features/modes/add_edit/bloc/mode_editor_bloc.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_allowed_pauses_tile.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_apps_selector_tile.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_icon_picker.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_icon_picker_sheet.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_schedule_panel.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_section_label.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_sticky_action_bar.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_upsert_draft_notifier.dart';
import 'package:pauza/src/features/modes/common/model/mode_icon.dart';
import 'package:pauza/src/features/modes/common/model/mode_upsert.dart';
import 'package:pauza/src/features/modes/common/model/week_day.dart';
import 'package:pauza/src/features/modes/list/widget/confirm_delete_mode_dialog.dart';
import 'package:pauza/src/features/modes/select_apps/widgets/android_apps_bottom_sheet.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class ModeEditorScreen extends StatelessWidget {
  const ModeEditorScreen({required this.modeId, super.key});

  factory ModeEditorScreen.create() => const ModeEditorScreen(modeId: null);

  factory ModeEditorScreen.edit({required String modeId}) => ModeEditorScreen(modeId: modeId);

  static void show(BuildContext context, {String? modeId}) {
    if (modeId == null) {
      HelmRouter.push(context, PauzaRoutes.modeCreate, rootNavigator: true);
    } else {
      HelmRouter.push(context, PauzaRoutes.modeEdit, pathParams: <String, String>{'midEdit': modeId}, rootNavigator: true);
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
  final ModeUpsertDraftNotifier _draftNotifier = ModeUpsertDraftNotifier();

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
    context.read<ModeEditorBloc>().add(ModeEditorLoadRequested(modeId: widget.modeId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ModeUpsertScope(
      notifier: _draftNotifier,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.modeId == null ? l10n.createModeTitle : l10n.editModeTitle)),
        body: BlocConsumer<ModeEditorBloc, ModeEditorState>(
          listener: (context, state) {
            if (state is ModeEditorReady) {
              _draftNotifier.configureForMode(initialDraft: state.request, isEditMode: state.modeId != null);
              if (!_initialized && mounted) {
                setState(() {
                  _initialized = true;
                });
              }
            }

            if (state is ModeEditorSaveSuccess || state is ModeEditorDeleteSuccess) {
              if (!mounted) {
                return;
              }
              Navigator.of(context).pop();
              return;
            }

            if (state is ModeEditorFailure && mounted) {
              final l10n = context.l10n;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(l10n.errorTitle)));
            }
          },
          builder: (context, state) {
            if (!_initialized) {
              return Center(
                child: switch (state) {
                  ModeEditorFailure() => Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: PauzaSpacing.medium,
                    children: <Widget>[
                      Text(l10n.modeLoadFailedMessage, style: context.textTheme.bodyLarge),
                      PauzaOutlinedButton(title: Text(l10n.retryButton), onPressed: _loadDraft),
                    ],
                  ),
                  _ => const CircularProgressIndicator(),
                },
              );
            }

            final isBusy = state is ModeEditorLoading;
            final draftNotifier = ModeUpsertScope.watch(context);
            final draft = draftNotifier.value;
            final validation = draftNotifier.validation;
            final schedule = draft.schedule;
            final isScheduleEnabled = schedule?.enabled ?? false;

            return Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(PauzaSpacing.medium, PauzaSpacing.medium, PauzaSpacing.medium, PauzaSpacing.large),
                    children: <Widget>[
                      Row(
                        spacing: PauzaSpacing.small,
                        children: [
                          ModeEditorIconPicker(
                            selectedIcon: draft.icon,
                            onTap: isBusy ? () {} : () => _onChooseIconPressed(context, draft.icon),
                          ),
                          Expanded(
                            child: PauzaTextFormField(
                              key: ValueKey<int>(draftNotifier.revision),
                              initialValue: draft.title,
                              onChanged: _draftNotifier.updateTitle,
                              decoration: PauzaInputDecoration(
                                labelText: l10n.modeTitleFieldLabel.toUpperCase(),
                                labelStyle: context.textTheme.labelLarge?.copyWith(
                                  color: context.colorScheme.primary,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w700,
                                ),
                                hintText: l10n.modeTitleFieldLabel,
                                errorText: _errorForField(context, validation[ModeUpsertValidationField.title]),
                              ),
                            ),
                          ),
                        ],
                      ),

                      PauzaTextFormField(
                        initialValue: draft.textOnScreen,
                        onChanged: _draftNotifier.updateTextOnScreen,
                        decoration: PauzaInputDecoration(
                          labelText: l10n.modeTextOnScreenFieldLabel.toUpperCase(),
                          labelStyle: context.textTheme.labelLarge?.copyWith(
                            color: context.colorScheme.primary,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                          ),
                          hintText: l10n.modeTextOnScreenFieldLabel,
                          errorText: _errorForField(context, validation[ModeUpsertValidationField.textOnScreen]),
                        ),
                      ),

                      PauzaTextFormField(
                        initialValue: draft.description ?? '',
                        onChanged: _draftNotifier.updateDescription,
                        maxLines: 3,
                        decoration: PauzaInputDecoration(
                          hintText: l10n.modeDescriptionFieldLabel,
                          labelText: l10n.modeDescriptionFieldLabel.toUpperCase(),
                          labelStyle: context.textTheme.labelLarge?.copyWith(
                            color: context.colorScheme.primary,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ModeEditorSectionLabel(label: l10n.modeBlockedAppsSectionTitle),
                          ModeEditorAppsSelectorTile(
                            title: l10n.modeBlockedAppsChooseButton,
                            subtitle: l10n.modeBlockedAppsSubtitle,
                            selectedCountLabel: l10n.modeBlockedAppsSelectedCountLabel(draft.blockedAppIds.length),
                            errorText: _errorForField(context, validation[ModeUpsertValidationField.blockedApps]),
                            onTap: isBusy
                                ? () {}
                                : () {
                                    onChooseAppsPressed(currentSelection: draft.blockedAppIds, onChanged: _draftNotifier.updateBlockedApps);
                                  },
                          ),
                        ],
                      ),

                      ModeEditorSchedulePanel(
                        title: l10n.modeScheduleTitle,
                        enabled: isScheduleEnabled,
                        onToggle: isBusy ? (_) {} : _draftNotifier.toggleScheduleEnabled,
                        days: WeekDay.values
                            .map(
                              (day) => ModeEditorDayChipItem(
                                id: day.name,
                                label: day.localizeShort(l10n).substring(0, 1),
                                isSelected: schedule?.days.contains(day) ?? false,
                              ),
                            )
                            .toList(growable: false),
                        onDayPressed: isBusy
                            ? (_) {}
                            : (dayName) {
                                _draftNotifier.toggleScheduleDay(WeekDay.values.firstWhere((day) => day.name == dayName));
                              },
                        startTitle: l10n.modeScheduleStartTimeLabel,
                        endTitle: l10n.modeScheduleEndTimeLabel,
                        startValue: _formatTime(context, schedule?.start),
                        endValue: _formatTime(context, schedule?.end),
                        onStartPressed: isBusy ? () {} : () => _onPickStartTime(context, schedule?.start, isStart: true),
                        onEndPressed: isBusy ? () {} : () => _onPickStartTime(context, schedule?.end, isStart: false),
                        errorText: _errorForField(context, validation[ModeUpsertValidationField.scheduleDays]),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ModeEditorSectionLabel(label: l10n.modeStrictnessTitle),
                          ModeEditorAllowedPausesTile(
                            title: l10n.modeAllowedPausesTitle,
                            subtitle: l10n.modeAllowedPausesSubtitle,
                            value: draft.allowedPausesCount,
                            canIncrement: draft.allowedPausesCount < ModeUpsertDraftNotifier.maxAllowedPauses,
                            canDecrement: draft.allowedPausesCount > ModeUpsertDraftNotifier.minAllowedPauses,
                            onIncrement: isBusy ? null : _draftNotifier.incrementPauses,
                            onDecrement: isBusy ? null : _draftNotifier.decrementPauses,
                          ),
                        ],
                      ),
                      if (widget.modeId != null)
                        Padding(
                          padding: const EdgeInsets.only(top: PauzaSpacing.medium),
                          child: PauzaTextButton(
                            size: PauzaButtonSize.large,
                            disabled: isBusy,
                            onPressed: _onDeletePressed,
                            title: Text(l10n.modeDeleteFocusButton),
                          ),
                        ),
                    ].interleaved(const SizedBox(height: PauzaSpacing.regular)).toList(),
                  ),
                ),
                ModeEditorStickyActionBar(buttonLabel: l10n.modeSaveButton, isBusy: isBusy, onPressed: () => _onSavePressed(context)),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatTime(BuildContext context, TimeOfDay? time) {
    final resolvedTime = time ?? const TimeOfDay(hour: 9, minute: 0);
    return MaterialLocalizations.of(context).formatTimeOfDay(resolvedTime);
  }

  Future<void> _onPickStartTime(BuildContext context, TimeOfDay? initial, {required bool isStart}) async {
    final picked = await showCupertinoTimePicker(context, doneButtonLabel: context.l10n.doneButton, initialTime: initial);
    if (!mounted || picked == null) {
      return;
    }
    if (isStart) {
      _draftNotifier.updateScheduleStart(picked);
    } else {
      _draftNotifier.updateScheduleEnd(picked);
    }
  }

  Future<void> onChooseAppsPressed({
    required ISet<AppIdentifier> currentSelection,
    required ValueChanged<ISet<AppIdentifier>> onChanged,
  }) async {
    final l10n = AppLocalizations.of(context);
    final rootScope = RootScope.of(context);

    try {
      if (kPauzaPlatform == PauzaPlatform.android) {
        final selectedIds = await AndroidAppsBottomSheet.show(context, initialSelectedAppIds: currentSelection);
        if (!mounted || selectedIds == null) {
          return;
        }
        onChanged(selectedIds.toISet());
        return;
      }

      final preSelectedApps = currentSelection.map((token) => IOSAppInfo(applicationToken: token)).toList(growable: false);
      final selectedApps = await rootScope.installedAppsRepository.selectIOSApps(preSelectedApps: preSelectedApps);
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

  Future<void> _onChooseIconPressed(BuildContext context, ModeIcon selectedIcon) async {
    final l10n = context.l10n;
    final nextIcon = await ModeIconPickerSheet.show(
      context,
      title: l10n.modeIconPickerTitle,
      subtitle: l10n.modeIconPickerSubtitle,
      selectedIcon: selectedIcon,
    );
    if (!mounted || nextIcon == null) {
      return;
    }
    _draftNotifier.updateIcon(nextIcon);
  }

  Future<void> _onDeletePressed() async {
    final shouldDelete = await ConfirmDeleteModeDialog.show(context);
    if (!mounted || shouldDelete != true) {
      return;
    }

    context.read<ModeEditorBloc>().add(ModeEditorDeleteRequested(modeId: widget.modeId));
  }

  void _onSavePressed(BuildContext context) {
    final validation = _draftNotifier.validateForSubmit();
    if (!validation.isValid) {
      return;
    }

    context.read<ModeEditorBloc>().add(ModeEditorSaveRequested(modeId: widget.modeId, request: _draftNotifier.buildSubmitRequest()));
  }

  String? _errorForField(BuildContext context, ModeUpsertValidationCode? error) {
    if (error == null) {
      return null;
    }
    final l10n = context.l10n;
    return switch (error) {
      ModeUpsertValidationCode.required => l10n.modeRequiredFieldError,
      ModeUpsertValidationCode.blockedAppsRequired => l10n.modeBlockedAppsRequiredError,
      ModeUpsertValidationCode.allowedPausesOutOfRange => l10n.modeAllowedPausesOutOfRangeError(
        ModeUpsertDraftNotifier.minAllowedPauses,
        ModeUpsertDraftNotifier.maxAllowedPauses,
      ),
      ModeUpsertValidationCode.scheduleDaysRequired => l10n.modeScheduleDaysRequiredError,
    };
  }
}
