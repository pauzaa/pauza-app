import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/profile/common/bloc/current_user_bloc.dart';
import 'package:pauza/src/features/profile/common/bloc/current_user_state.dart';
import 'package:pauza/src/features/profile/edit/widget/profile_edit_screen.dart';
import 'package:pauza/src/features/profile/view/widget/profile_action_card.dart';
import 'package:pauza/src/features/profile/view/widget/profile_header_section.dart';
import 'package:pauza/src/features/settings/widget/settings_screen.dart';
import 'package:pauza/src/features/subscription/widget/paywall_screen.dart';
import 'package:pauza/src/features/subscription/widget/subscription_info_screen.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: PauzaSpacing.large, vertical: PauzaSpacing.large),
          children: <Widget>[
            PauzaDashboardAppBar(title: l10n.profileTitle),
            const SizedBox(height: PauzaSpacing.extraLarge),
            BlocBuilder<CurrentUserBloc, CurrentUserState>(
              bloc: RootScope.of(context).currentUserBloc,
              builder: (context, state) {
                final user = state.user;
                final displayName = switch (state.status) {
                  CurrentUserStatus.available => user?.name ?? l10n.profileDisplayNameFallback,
                  _ => l10n.profileDisplayNameFallback,
                };
                final username = switch (state.status) {
                  CurrentUserStatus.available => user?.username ?? l10n.profileUsernameFallback,
                  _ => l10n.profileUsernameFallback,
                };
                final profilePictureUrl = switch (state.status) {
                  CurrentUserStatus.available => user?.profilePicture,
                  _ => null,
                };
                final isSubscribed = user?.subscription?.isActive == true;

                return Column(
                  children: <Widget>[
                    ProfileHeaderSection(
                      profilePictureUrl: profilePictureUrl,
                      displayName: displayName,
                      username: username,
                    ),
                    const SizedBox(height: PauzaSpacing.xLarge),
                    Padding(
                      padding: const EdgeInsets.only(bottom: PauzaSpacing.medium),
                      child: ProfileActionCard(
                        icon: Icons.workspace_premium_rounded,
                        title: l10n.paywallTitle,
                        onTap: () => isSubscribed
                            ? SubscriptionInfoScreen.show(context)
                            : PaywallScreen.show(context),
                      ),
                    ),
                  ],
                );
              },
            ),
            ProfileActionCard(
              icon: Icons.edit_note_rounded,
              title: l10n.profileEditInfoNavTitle,
              onTap: () {
                ProfileEditScreen.show(context);
              },
            ),
            const SizedBox(height: PauzaSpacing.medium),
            ProfileActionCard(
              icon: Icons.settings_rounded,
              title: l10n.profileSettingsNavTitle,
              onTap: () {
                SettingsScreen.show(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
