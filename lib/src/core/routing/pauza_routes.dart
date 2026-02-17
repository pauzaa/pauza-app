import 'package:flutter/widgets.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/features/auth/widget/auth_screen.dart';
import 'package:pauza/src/features/auth/widget/otp_screen.dart';
import 'package:pauza/src/features/leaderboard/widget/leaderboard_screen.dart';
import 'package:pauza/src/features/navigation/widget/dashboard_tabs_shell.dart';
import 'package:pauza/src/features/home/widget/home_screen.dart';
import 'package:pauza/src/features/modes/add_edit/widgets/mode_editor_screen.dart';
import 'package:pauza/src/features/not_found/widget/not_found_screen.dart';
import 'package:pauza/src/features/permissions/widget/permissions_screen.dart';
import 'package:pauza/src/features/profile/edit/widget/profile_edit_screen.dart';
import 'package:pauza/src/features/profile/view/widget/profile_screen.dart';
import 'package:pauza/src/features/settings/widget/settings_screen.dart';
import 'package:pauza/src/features/stats/common/widget/stats_screen.dart';

enum PauzaRoutes with Routable {
  root,
  home,
  stats,
  leaderboard,
  profile,
  profileEdit,
  modeCreate,
  modeEdit,

  permissions,
  auth,
  otp,
  settings,
  notFound;

  @override
  String get path => switch (this) {
    PauzaRoutes.root => '/',
    PauzaRoutes.home => '/home',
    PauzaRoutes.stats => '/stats',
    PauzaRoutes.leaderboard => '/leaderboard',
    PauzaRoutes.profile => '/profile',
    PauzaRoutes.profileEdit => '/profile/edit',
    PauzaRoutes.modeCreate => '/modes/new',
    PauzaRoutes.modeEdit => '/modes/{midEdit}/edit',
    PauzaRoutes.permissions => '/permissions',
    PauzaRoutes.auth => '/auth',
    PauzaRoutes.otp => '/auth/otp',
    PauzaRoutes.settings => '/settings',
    PauzaRoutes.notFound => '/404',
  };

  @override
  PageType get pageType => switch (this) {
    PauzaRoutes.root ||
    PauzaRoutes.home ||
    PauzaRoutes.stats ||
    PauzaRoutes.leaderboard ||
    PauzaRoutes.profile ||
    PauzaRoutes.profileEdit ||
    PauzaRoutes.modeCreate ||
    PauzaRoutes.modeEdit ||
    PauzaRoutes.permissions ||
    PauzaRoutes.auth ||
    PauzaRoutes.otp ||
    PauzaRoutes.settings ||
    PauzaRoutes.notFound => PageType.material,
  };

  @override
  Widget builder(
    Map<String, String> pathParams,
    Map<String, String> queryParams,
  ) => switch (this) {
    PauzaRoutes.root => const DashboardTabsShell(),
    PauzaRoutes.home => const HomeScreen(),
    PauzaRoutes.stats => const StatsScreen(),
    PauzaRoutes.leaderboard => const LeaderboardScreen(),
    PauzaRoutes.profile => const ProfileScreen(),
    PauzaRoutes.profileEdit => const ProfileEditScreen(),
    PauzaRoutes.modeCreate => ModeEditorScreen.create(),
    PauzaRoutes.modeEdit => ModeEditorScreen.edit(
      modeId: pathParams['midEdit'] ?? '',
    ),
    PauzaRoutes.permissions => const PermissionsScreen(),
    PauzaRoutes.auth => const AuthScreen(),
    PauzaRoutes.otp => const OtpScreen(),
    PauzaRoutes.settings => const SettingsScreen(),
    PauzaRoutes.notFound => const NotFoundScreen(),
  };
}
