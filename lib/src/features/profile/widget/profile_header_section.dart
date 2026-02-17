import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class ProfileHeaderSection extends StatelessWidget {
  const ProfileHeaderSection({
    required this.displayName,
    required this.username,
    super.key,
    this.profilePictureUrl,
  });

  final String? profilePictureUrl;
  final String displayName;
  final String username;

  @override
  Widget build(BuildContext context) {
    final hasProfilePicture =
        profilePictureUrl != null && profilePictureUrl!.trim().isNotEmpty;

    return Column(
      children: <Widget>[
        SizedBox(
          width: 180,
          height: 180,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colorScheme.surfaceContainerHigh,
              border: Border.all(color: context.colorScheme.primary, width: 3),
            ),
            child: ClipOval(
              child: hasProfilePicture
                  ? Image.network(
                      profilePictureUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person_rounded,
                          size: PauzaIconSizes.xxLarge,
                          color: context.colorScheme.onSurfaceVariant,
                        );
                      },
                    )
                  : Icon(
                      Icons.person_rounded,
                      size: PauzaIconSizes.xxLarge,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
            ),
          ),
        ),
        const SizedBox(height: PauzaSpacing.large),
        Text(
          displayName,
          textAlign: TextAlign.center,
          style: context.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
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
