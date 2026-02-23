import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza/src/features/modes/add_edit/bloc/mode_editor_bloc.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_allowed_pauses_tile.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_apps_selector_tile.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_ending_pausing_scenario_panel.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_icon_picker.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_minimum_duration_tile.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_schedule_panel.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_section_label.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_sticky_action_bar.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_upsert_draft_notifier.dart';
import 'package:pauza/src/features/modes/common/model/mode_upsert.dart';
import 'package:pauza/src/features/modes/list/widget/confirm_delete_mode_dialog.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class ModeEditorScreen extends StatelessWidget {
  const ModeEditorScreen({required this.modeId, super.key});

  factory ModeEditorScreen.create() => const ModeEditorScreen(modeId: null);

  factory ModeEditorScreen.edit({required String modeId}) => ModeEditorScreen(modeId: modeId);

  static void show(BuildContext context, {String? modeId}) {
    if (modeId == null) {
      HelmRouter.push(context, PauzaRoutes.modeCreate, rootNavigator: true);
    } else {
      HelmRouter.push(
        context,
        PauzaRoutes.modeEdit,
        pathParams: <String, String>{'midEdit': modeId},
        rootNavigator: true,
      );
    }
  }

  final String? modeId;

  @override
  Widget build(BuildContext context) {
    final rootScope = RootScope.of(context);
    return BlocProvider(
      create: (context) =>
          ModeEditorBloc(modesRepository: rootScope.modesRepository, hasNfcSupport: rootScope.hasNfcSupport),
      child: ModeEditorMainScreen(modeId: modeId, hasNfcSupport: rootScope.hasNfcSupport),
    );
  }
}

class ModeEditorMainScreen extends StatefulWidget {
  const ModeEditorMainScreen({required this.modeId, required this.hasNfcSupport, super.key});

  final String? modeId;
  final bool hasNfcSupport;

  @override
  State<ModeEditorMainScreen> createState() => _ModeEditorMainScreenState();
}

class _ModeEditorMainScreenState extends State<ModeEditorMainScreen> {
  late final ModeUpsertDraftNotifier _draftNotifier;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _draftNotifier = ModeUpsertDraftNotifier(hasNfcSupport: widget.hasNfcSupport);
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
              _draftNotifier.ensureEndingPausingScenarioCompatibility();
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

            return Column(
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
                      Row(
                        spacing: PauzaSpacing.small,
                        children: [
                          ModeEditorIconPicker(selectedIcon: draft.icon, enabled: !isBusy),
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
                            selectedCountLabel: draft.blockedAppIds.length.toString(),
                            errorText: _errorForField(context, validation[ModeUpsertValidationField.blockedApps]),
                            enabled: !isBusy,
                          ),
                        ],
                      ),

                      ModeEditorSchedulePanel(
                        title: l10n.modeScheduleTitle,
                        startTitle: l10n.modeScheduleStartTimeLabel,
                        endTitle: l10n.modeScheduleEndTimeLabel,
                        errorText: _errorForField(context, validation[ModeUpsertValidationField.scheduleDays]),
                        enabled: !isBusy,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ModeEditorSectionLabel(label: l10n.modeStrictnessTitle),
                          ModeEditorMinimumDurationTile(
                            title: l10n.modeMinimumDurationTitle,
                            subtitle: l10n.modeMinimumDurationSubtitle,
                            duration: draft.minimumDuration,
                            actionLabel: l10n.modeMinimumDurationSetButton,
                            clearLabel: draft.minimumDuration == null ? null : l10n.modeMinimumDurationClearButton,
                            enabled: !isBusy,
                          ),
                          ModeEditorEndingPausingScenarioPanel(
                            title: l10n.modeEndingPausingScenarioTitle,
                            subtitle: l10n.modeEndingPausingScenarioSubtitle,
                            nfcLabel: l10n.modeEndingPausingScenarioNfc,
                            qrLabel: l10n.modeEndingPausingScenarioQrCode,
                            manualLabel: l10n.modeEndingPausingScenarioManual,
                            selectedScenario: draft.endingPausingScenario,
                            nfcDisabled: !widget.hasNfcSupport,
                            nfcDisabledHint: !widget.hasNfcSupport ? l10n.modeEndingPausingScenarioNfcDisabled : null,
                            onScenarioPressed: isBusy ? (_) {} : _draftNotifier.updateEndingPausingScenario,
                          ),
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
                ModeEditorStickyActionBar(
                  buttonLabel: l10n.modeSaveButton,
                  isBusy: isBusy,
                  onPressed: () => _onSavePressed(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _onDeletePressed() async {
    final shouldDelete = await ConfirmDeleteModeDialog.show(context);
    if (!mounted || shouldDelete != true) {
      return;
    }

    context.read<ModeEditorBloc>().add(ModeEditorDeleteRequested(modeId: widget.modeId));
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

  void _onSavePressed(BuildContext context) {
    final validation = _draftNotifier.validateForSubmit();
    if (!validation.isValid) {
      return;
    }

    context.read<ModeEditorBloc>().add(
      ModeEditorSaveRequested(modeId: widget.modeId, request: _draftNotifier.buildSubmitRequest()),
    );
  }
}
