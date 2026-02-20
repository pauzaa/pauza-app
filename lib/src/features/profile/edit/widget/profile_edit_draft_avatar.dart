import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class ProfileEditDraftAvatar extends StatelessWidget {
  const ProfileEditDraftAvatar({
    required this.radius,
    this.imageUrl,
    this.imageBytes,
    super.key,
  });

  final String? imageUrl;
  final Uint8List? imageBytes;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PauzaUserAvatar(
          imageUrl: imageUrl,
          radius: radius,
          imageBytes: imageBytes,
        ),
        Positioned(
          bottom: 2,
          right: 5,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(PauzaSpacing.small),
              child: Icon(
                Icons.edit_rounded,
                color: context.colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
