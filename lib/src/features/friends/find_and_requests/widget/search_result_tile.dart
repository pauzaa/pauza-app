import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/friends/common/model/basic_user_dto.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class SearchResultTile extends StatelessWidget {
  const SearchResultTile({required this.user, required this.isActionInProgress, required this.onAdd, super.key});

  final BasicUserDto user;
  final bool isActionInProgress;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final colors = context.pauzaColorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          PauzaUserAvatar(imageUrl: user.profilePictureUrl, radius: PauzaAvatarSizes.small),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: textTheme.titleSmall, overflow: TextOverflow.ellipsis),
                Text(
                  '@${user.username}',
                  style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          PauzaFilledButton(
            title: Text(l10n.findAndRequestsAddButton),
            onPressed: onAdd,
            disabled: isActionInProgress,
            size: PauzaButtonSize.small,
          ),
        ],
      ),
    );
  }
}
