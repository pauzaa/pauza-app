import 'package:flutter/material.dart';
import 'package:pauza/src/features/profile/view/widget/profile_avatar.dart';

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
    return ProfileAvatar(
      profilePictureUrl: profilePictureUrl,
      displayName: displayName,
      username: username,
    );
  }
}
