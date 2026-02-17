import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/profile/common/bloc/current_user_state.dart';
import 'package:pauza/src/features/profile/widget/profile_action_card.dart';
import 'package:pauza/src/features/profile/widget/profile_header_section.dart';
import 'package:pauza/src/features/profile/widget/profile_placeholder_screen.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class ProfileContent extends StatelessWidget {
  const ProfileContent({required this.state, super.key});

  final CurrentUserState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = state.user;
    final displayName = switch (state.status) {
      CurrentUserStatus.available =>
        user?.name ?? l10n.profileDisplayNameFallback,
      _ => l10n.profileDisplayNameFallback,
    };
    final username = switch (state.status) {
      CurrentUserStatus.available =>
        user?.username ?? l10n.profileUsernameFallback,
      _ => l10n.profileUsernameFallback,
    };
    final profilePictureUrl = switch (state.status) {
      CurrentUserStatus.available => user?.profilePicture,
      _ => null,
    };

    return Scaffold(
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: PauzaSpacing.large,
            vertical: PauzaSpacing.large,
          ),
          children: <Widget>[
            PauzaDashboardAppBar(
              greeting: l10n.profileTitle,
              title: l10n.profileTitle,
              showGreeting: false,
              showSettingsButton: false,
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: PauzaSpacing.extraLarge),
            ProfileHeaderSection(
              profilePictureUrl: profilePictureUrl,
              displayName: displayName,
              username: username,
            ),
            const SizedBox(height: PauzaSpacing.xLarge),
            ProfileActionCard(
              icon: Icons.edit_note_rounded,
              title: l10n.profileEditInfoNavTitle,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) {
                      return ProfilePlaceholderScreen(
                        title: l10n.profileEditInfoNavTitle,
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: PauzaSpacing.medium),
            ProfileActionCard(
              icon: Icons.settings_rounded,
              title: l10n.profileSettingsNavTitle,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) {
                      return ProfilePlaceholderScreen(
                        title: l10n.profileSettingsNavTitle,
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
