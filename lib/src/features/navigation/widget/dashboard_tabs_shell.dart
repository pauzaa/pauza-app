import 'package:flutter/material.dart' hide NavigationDestination;
import 'package:helm/helm.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class DashboardTabsShell extends StatelessWidget {
  const DashboardTabsShell({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return NestedTabsNavigator(
      tabs: const <PauzaRoutes>[
        PauzaRoutes.home,
        PauzaRoutes.stats,
        PauzaRoutes.leaderboard,
        PauzaRoutes.profile,
      ],
      initialTab: PauzaRoutes.home,
      builder: (context, child, selectedIndex, onTabPressed) {
        return Scaffold(
          body: child,
          bottomNavigationBar: PauzaBottomNavigationBar(
            destinations: [
              PauzaNavigationDestination(
                icon: Icons.home_rounded,
                label: l10n.homeTitle,
              ),
              PauzaNavigationDestination(
                icon: Icons.bar_chart_rounded,
                label: l10n.statsTitle,
              ),
              PauzaNavigationDestination(
                icon: Icons.leaderboard,
                label: l10n.leaderboardTitle,
              ),
              PauzaNavigationDestination(
                icon: Icons.person_rounded,
                label: l10n.profileTitle,
              ),
            ],
            selectedIndex: selectedIndex,
            onTabPressed: onTabPressed,
          ),
        );
      },
    );
  }
}
