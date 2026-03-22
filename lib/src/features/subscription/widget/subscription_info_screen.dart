import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helm/helm.dart';
import 'package:intl/intl.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/core/init/pauza_dependencies.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza/src/features/profile/common/bloc/current_user_bloc.dart';
import 'package:pauza/src/features/profile/common/bloc/current_user_state.dart';
import 'package:pauza/src/features/profile/common/model/subscription_dto.dart';
import 'package:pauza/src/features/profile/common/model/subscription_source.dart';
import 'package:pauza/src/features/subscription/widget/paywall_screen.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionInfoScreen extends StatelessWidget {
  const SubscriptionInfoScreen({super.key});

  static void show(BuildContext context) {
    HelmRouter.push(context, PauzaRoutes.subscriptionInfo);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.subscriptionInfoTitle), centerTitle: true),
      body: SafeArea(
        child: BlocBuilder<CurrentUserBloc, CurrentUserState>(
          bloc: RootScope.of(context).currentUserBloc,
          buildWhen: (previous, current) => previous.user?.subscription != current.user?.subscription,
          builder: (context, state) {
            final subscription = state.user?.subscription;

            if (subscription == null) {
              return _SubscriptionEmptyState();
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: PauzaSpacing.large),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: PauzaSpacing.extraLarge),
                  _SubscriptionHeroCard(subscription: subscription),
                  const SizedBox(height: PauzaSpacing.extraLarge),
                  if (subscription.currentPeriodEnd != null)
                    _SubscriptionDetailTile(
                      icon: Icons.calendar_today_rounded,
                      title: subscription.isActive
                          ? l10n.subscriptionInfoRenewalDateLabel
                          : l10n.subscriptionInfoExpiryDateLabel,
                      trailing: DateFormat.yMMMd().format(subscription.currentPeriodEnd!),
                    ),
                  if (subscription.source != null) ...[
                    const SizedBox(height: PauzaSpacing.medium),
                    _SubscriptionDetailTile(
                      icon: Icons.storefront_rounded,
                      title: l10n.subscriptionInfoSourceLabel,
                      trailing: switch (subscription.source!) {
                        SubscriptionSource.revenuecat => l10n.subscriptionInfoSourceRevenuecat,
                        SubscriptionSource.adminOverride => l10n.subscriptionInfoSourceAdminOverride,
                      },
                    ),
                  ],
                  const Spacer(),
                  if (subscription.source != SubscriptionSource.adminOverride)
                    PauzaFilledButton(
                      title: Text(l10n.subscriptionInfoManageButton),
                      onPressed: () => _openManageSubscriptions(context),
                    ),
                  const SizedBox(height: PauzaSpacing.extraLarge),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openManageSubscriptions(BuildContext context) async {
    final repo = PauzaDependencies.of(context).subscriptionRepository;
    try {
      final url = await repo.getManagementUrl();
      if (url != null) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } on Object catch (e) {
      log('SubscriptionInfoScreen: failed to open management URL: $e', name: 'subscription');
    }
  }
}

class _SubscriptionHeroCard extends StatelessWidget {
  const _SubscriptionHeroCard({required this.subscription});

  final SubscriptionDto subscription;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final borderColor = context.colorScheme.primary.withValues(alpha: 0.45);

    return Material(
      color: context.colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PauzaSpacing.large),
        child: Row(
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(PauzaCornerRadius.medium),
                color: context.colorScheme.primary.withValues(alpha: 0.16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(PauzaSpacing.medium),
                child: Icon(Icons.workspace_premium_rounded, size: 32, color: context.colorScheme.primary),
              ),
            ),
            const SizedBox(width: PauzaSpacing.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.subscriptionInfoPremiumPlan,
                    style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: PauzaSpacing.small),
                  _SubscriptionStatusBadge(subscription: subscription),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionStatusBadge extends StatelessWidget {
  const _SubscriptionStatusBadge({required this.subscription});

  final SubscriptionDto subscription;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pauzaColors = context.pauzaColorScheme;

    final ({Color color, IconData icon, String text}) badge;

    if (!subscription.isActive) {
      badge = (color: context.colorScheme.error, icon: Icons.cancel_rounded, text: l10n.subscriptionInfoInactiveStatus);
    } else if (subscription.isExpiringSoon) {
      badge = (
        color: pauzaColors.warning,
        icon: Icons.warning_rounded,
        text: l10n.subscriptionInfoExpiringSoonStatus,
      );
    } else {
      badge = (
        color: pauzaColors.success,
        icon: Icons.check_circle_rounded,
        text: l10n.subscriptionInfoActiveStatus,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: PauzaSpacing.medium, vertical: PauzaSpacing.tiny),
      decoration: BoxDecoration(
        color: badge.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(badge.icon, size: 16, color: badge.color),
          const SizedBox(width: PauzaSpacing.tiny),
          Text(
            badge.text,
            style: context.textTheme.labelMedium?.copyWith(color: badge.color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionDetailTile extends StatelessWidget {
  const _SubscriptionDetailTile({required this.icon, required this.title, required this.trailing});

  final IconData icon;
  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    final borderColor = context.colorScheme.primary.withValues(alpha: 0.45);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
      side: BorderSide(color: borderColor),
    );

    return Material(
      color: context.colorScheme.surfaceContainerLowest,
      shape: shape,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PauzaSpacing.medium, vertical: PauzaSpacing.regular),
        child: Row(
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(PauzaCornerRadius.medium),
                color: context.colorScheme.primary.withValues(alpha: 0.16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(PauzaSpacing.medium),
                child: Icon(icon, color: context.colorScheme.primary),
              ),
            ),
            const SizedBox(width: PauzaSpacing.medium),
            Expanded(
              child: Text(title, style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ),
            Text(
              trailing,
              style: context.textTheme.bodyLarge?.copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PauzaSpacing.large),
      child: Column(
        children: <Widget>[
          const Spacer(),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(PauzaCornerRadius.medium),
              color: context.colorScheme.onSurface.withValues(alpha: 0.08),
            ),
            child: Padding(
              padding: const EdgeInsets.all(PauzaSpacing.medium),
              child: Icon(Icons.workspace_premium_rounded, size: 48, color: context.colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: PauzaSpacing.large),
          Text(
            l10n.subscriptionInfoNoSubscription,
            style: context.textTheme.titleMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
          const Spacer(),
          PauzaFilledButton(
            title: Text(l10n.subscriptionInfoGetPremium),
            onPressed: () => PaywallScreen.show(context),
          ),
          const SizedBox(height: PauzaSpacing.extraLarge),
        ],
      ),
    );
  }
}
