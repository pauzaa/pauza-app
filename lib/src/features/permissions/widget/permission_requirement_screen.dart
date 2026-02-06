import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/pauza_dependencies.dart';
import 'package:pauza/src/core/localization/gen/app_localizations.dart';
import 'package:pauza/src/core/permissions/pauza_permission_requirement.dart';
import 'package:pauza/src/core/permissions/permission_gate_state.dart';
import 'package:pauza/src/core/permissions/permission_helper.dart';
import 'package:pauza/src/features/permissions/common/permission_status_label.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class PermissionRequirementScreen extends StatelessWidget {
  const PermissionRequirementScreen({
    required this.requirement,
    required this.title,
    required this.body,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
    super.key,
  });

  final PauzaPermissionRequirement requirement;
  final String title;
  final String body;
  final String primaryActionLabel;
  final Future<void> Function(PauzaPermissionGate gate) onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final dependencies = PauzaDependencies.of(context);
    final gate = dependencies.permissionGate;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appName)),
      body: SafeArea(
        child: StreamBuilder<PermissionGateState>(
          stream: gate.stream,
          initialData: gate.state,
          builder: (context, snapshot) {
            final gateState = snapshot.data ?? gate.state;
            final status = gateState.statusOf(requirement);

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Text(body, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 24),
                  Text(
                    l10n.permissionCurrentStatusLabel(status.label(l10n)),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (gateState.lastError != null) ...<Widget>[
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.errorTitle}: ${gateState.lastError}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const Spacer(),
                  PauzaFilledButton(
                    onPressed: () async {
                      await onPrimaryAction(gate);
                    },
                    title: Text(primaryActionLabel),
                  ),
                  const SizedBox(height: 12),
                  PauzaOutlinedButton(
                    onPressed: () async {
                      await gate.refresh(force: true);
                    },
                    title: Text(l10n.retryButton),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
