import 'package:flutter/material.dart';
import 'package:pauza/src/core/common/extensions.dart';
import 'package:pauza/src/core/init/pauza_dependencies.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/permissions/model/pauza_permission_requirement.dart';
import 'package:pauza/src/features/permissions/widget/permission_requirement_row.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dependencies = PauzaDependencies.of(context);
    final gate = dependencies.permissionGate;
    final l10n = context.l10n;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.appName),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: gate,
            builder: (context, _) {
              final gateState = gate.state;
              final requirements =
                  PauzaPermissionRequirement.requiredForCurrentPlatform;

              return ListView(
                padding: const EdgeInsets.all(PauzaSpacing.large),
                physics: const BouncingScrollPhysics(),
                children:
                    <Widget>[
                          const Align(child: _PermissionsHero()),
                          Text(
                            l10n.permissionsRequiredTitle,
                            style: context.textTheme.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            l10n.permissionsRequiredBody,
                            style: context.textTheme.bodyLarge?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          ...requirements.map((requirement) {
                            final status = gateState.statusOf(requirement);
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: PauzaSpacing.medium,
                              ),
                              child: PermissionRequirementRow(
                                requirement: requirement,
                                status: status,
                                onTap: () async {
                                  await gate.request(requirement);
                                },
                              ),
                            );
                          }),
                          if (gateState.lastError != null) ...<Widget>[
                            Text(
                              '${l10n.errorTitle}: ${gateState.lastError}',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.error,
                              ),
                            ),
                          ],
                        ]
                        .interleaved(const SizedBox(height: PauzaSpacing.small))
                        .toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PermissionsHero extends StatelessWidget {
  const _PermissionsHero();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        SizedBox(
          width: 132,
          height: 132,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colorScheme.primary.withValues(alpha: 0.08),
              border: Border.all(
                color: context.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              Icons.verified_user,
              size: 52,
              color: context.colorScheme.primary,
            ),
          ),
        ),
        Positioned(
          right: -8,
          bottom: -8,
          child: SizedBox(
            width: 52,
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.lock_open,
                color: context.colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
