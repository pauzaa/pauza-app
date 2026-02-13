import 'package:flutter/widgets.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/permissions/model/pauza_permission_requirement.dart';
import 'package:pauza/src/features/permissions/widget/permission_requirement_screen.dart';

class AndroidExactAlarmPermissionScreen extends StatelessWidget {
  const AndroidExactAlarmPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const requirement = PauzaPermissionRequirement.androidExactAlarm;

    return PermissionRequirementScreen(
      requirement: requirement,
      title: requirement.title(l10n),
      body: requirement.body(l10n),
      primaryActionLabel: requirement.primaryActionLabel(l10n),
      onPrimaryAction: (helper) => helper.request(requirement),
    );
  }
}
