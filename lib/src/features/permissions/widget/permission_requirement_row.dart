import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/permissions/model/pauza_permission_requirement.dart';
import 'package:pauza_screen_time/pauza_screen_time.dart' show PermissionStatus;
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class PermissionRequirementRow extends StatelessWidget {
  const PermissionRequirementRow({
    required this.requirement,
    required this.status,
    required this.onTap,
    super.key,
  });

  final PauzaPermissionRequirement requirement;
  final PermissionStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isGranted = status.isGranted;

    return PauzaListTileCard(
      title: requirement.title(l10n),
      subtitle: requirement.shortBody(l10n),
      borderColor: isGranted ? context.pauzaColorScheme.success : null,
      enabled: !isGranted,
      onTap: onTap,
      borderWidth: isGranted ? 2 : 1,
      leading: _PermissionLeadingIcon(iconData: requirement.iconData),
      trailing: Icon(
        isGranted ? Icons.done : Icons.chevron_right,
        color: isGranted
            ? context.pauzaColorScheme.success
            : context.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _PermissionLeadingIcon extends StatelessWidget {
  const _PermissionLeadingIcon({required this.iconData});

  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color: context.colorScheme.primary, size: 48),
    );
  }
}
