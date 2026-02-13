import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/core/common/pauza_platform.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/modes/add_edit/bloc/mode_editor_bloc.dart';
import 'package:pauza/src/features/modes/select_apps/widgets/android_apps_bottom_sheet.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_upsert_draft_notifier.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart';

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
    return ModeUpsertScope(
      notifier: _draftNotifier,
      child: Form(key: _formKey, child: const Placeholder()),
    );
  }

  Future<void> onChooseAppsPressed({
    required Set<AppIdentifier> currentSelection,
    required ValueChanged<ISet<AppIdentifier>> onChanged,
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
            return AndroidAppsBottomSheet(initialSelectedAppIds: currentSelection);
          },
        );
        if (!mounted || selectedIds == null) {
          return;
        }
        onChanged(selectedIds.toISet());
        return;
      } else {
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
      }
    } on Object {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.modeAppsLoadFailedMessage)));
    }
  }

  void onSavePressed(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final draft = _draftNotifier.value;

    context.read<ModeEditorBloc>().add(
      ModeEditorSaveRequested(modeId: widget.modeId, request: draft),
    );
  }
}
