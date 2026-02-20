import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class ProfilePhotoActionSheet extends StatelessWidget {
  const ProfilePhotoActionSheet({super.key});

  static Future<ImageSource?> show(BuildContext context) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const ProfilePhotoActionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.all(PauzaSpacing.medium),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            l10n.profileEditChangePhotoSheetTitle,
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: PauzaSpacing.medium),
          _PhotoActionTile(
            icon: Icons.photo_camera_rounded,
            title: l10n.profileEditTakePhotoTitle,
            subtitle: l10n.profileEditTakePhotoSubtitle,
            onTap: () {
              Navigator.of(context).pop(ImageSource.camera);
            },
          ),
          const SizedBox(height: PauzaSpacing.regular),
          _PhotoActionTile(
            icon: Icons.image_rounded,
            title: l10n.profileEditChooseFromGalleryTitle,
            subtitle: l10n.profileEditChooseFromGallerySubtitle,
            onTap: () {
              Navigator.of(context).pop(ImageSource.gallery);
            },
          ),
          const SizedBox(height: PauzaSpacing.large),
          PauzaOutlinedButton(
            onPressed: Navigator.of(context).pop,
            title: Text(l10n.cancelButton),
            size: PauzaButtonSize.large,
          ),
        ],
      ),
    );
  }
}

class _PhotoActionTile extends StatelessWidget {
  const _PhotoActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(PauzaCornerRadius.large),
          border: Border.all(color: context.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(PauzaSpacing.medium),
          child: Row(
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colorScheme.primary.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(PauzaSpacing.regular),
                  child: Icon(icon, color: context.colorScheme.primary),
                ),
              ),
              const SizedBox(width: PauzaSpacing.regular),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: PauzaSpacing.small,
                  children: <Widget>[
                    Text(
                      title,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
