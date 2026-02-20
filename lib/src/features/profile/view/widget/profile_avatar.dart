import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({required this.profilePictureUrl, required this.displayName, required this.username, super.key});

  final String? profilePictureUrl;
  final String displayName;
  final String username;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        PauzaUserAvatar(imageUrl: profilePictureUrl, radius: 90),
        const SizedBox(height: PauzaSpacing.large),
        Text(
          displayName,
          textAlign: TextAlign.center,
          style: context.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: PauzaSpacing.small),
        Text(
          '@$username',
          textAlign: TextAlign.center,
          style: context.textTheme.titleLarge?.copyWith(
            color: context.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
