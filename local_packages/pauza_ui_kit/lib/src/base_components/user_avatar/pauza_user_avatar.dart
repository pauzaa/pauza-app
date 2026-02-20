import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

final class PauzaUserAvatar extends StatelessWidget {
  const PauzaUserAvatar({
    this.imageUrl,
    this.imageBytes,
    this.radius = PauzaAvatarSizes.medium,
    this.borderWidth = 3,
    super.key,
  });

  final String? imageUrl;
  final Uint8List? imageBytes;
  final double radius;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final urlImage = imageUrl;
    final bytes = imageBytes;
    final hasBytes = (bytes != null && bytes.isNotEmpty);
    final hasUrl = (urlImage != null && urlImage.isNotEmpty);
    final hasImage = hasUrl || hasBytes;

    final imageProvider =
        (hasImage
                ? hasBytes
                      ? MemoryImage(bytes)
                      : CachedNetworkImageProvider(urlImage!)
                : null)
            as ImageProvider<Object>?;

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: context.colorScheme.primary,
          width: borderWidth,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: context.colorScheme.surfaceContainerHigh,
        foregroundImage: imageProvider,
        onForegroundImageError: hasImage ? (_, _) {} : null,
        child: _FallbackIcon(radius: radius),
      ),
    );
  }
}

final class _FallbackIcon extends StatelessWidget {
  const _FallbackIcon({required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.person_rounded,
      size: radius * 0.7,
      color: context.colorScheme.onSurfaceVariant,
    );
  }
}
