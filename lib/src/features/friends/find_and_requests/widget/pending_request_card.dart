import 'package:flutter/material.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/friends/common/model/friend_request_dto.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class PendingRequestCard extends StatelessWidget {
  const PendingRequestCard({
    required this.request,
    required this.isIncoming,
    required this.isActionInProgress,
    this.onAccept,
    this.onDecline,
    this.onCancel,
    super.key,
  });

  final FriendRequestDto request;
  final bool isIncoming;
  final bool isActionInProgress;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors = context.pauzaColorScheme;
    final diff = DateTime.now().toUtc().difference(request.createdAt);
    final String timeAgo;
    if (diff.inDays > 0) {
      timeAgo = l10n.timeAgoDays(diff.inDays);
    } else if (diff.inHours > 0) {
      timeAgo = l10n.timeAgoHours(diff.inHours);
    } else if (diff.inMinutes > 0) {
      timeAgo = l10n.timeAgoMinutes(diff.inMinutes);
    } else {
      timeAgo = l10n.timeAgoJustNow;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            PauzaUserAvatar(imageUrl: request.user.profilePictureUrl, radius: PauzaAvatarSizes.small),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(request.user.name, style: textTheme.titleSmall, overflow: TextOverflow.ellipsis),
                  Text(
                    isIncoming ? l10n.findAndRequestsReceivedAgo(timeAgo) : l10n.findAndRequestsSentAgo(timeAgo),
                    style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            if (isIncoming) ...[
              PauzaFilledButton(
                title: Text(l10n.findAndRequestsAccept),
                onPressed: onAccept ?? () {},
                disabled: isActionInProgress,
                size: PauzaButtonSize.small,
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: isActionInProgress ? null : onDecline,
                iconSize: 20,
              ),
            ] else
              PauzaOutlinedButton(
                title: Text(l10n.findAndRequestsCancel),
                onPressed: onCancel ?? () {},
                disabled: isActionInProgress,
                size: PauzaButtonSize.small,
              ),
          ],
        ),
      ),
    );
  }
}
