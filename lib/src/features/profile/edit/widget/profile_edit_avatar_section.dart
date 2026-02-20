import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/profile/edit/domain/user_edit_draft_notifier.dart';
import 'package:pauza/src/features/profile/edit/widget/profile_edit_draft_avatar.dart';
import 'package:pauza/src/features/profile/edit/widget/profile_photo_action_sheet.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class ProfileEditAvatarSection extends StatelessWidget {
  const ProfileEditAvatarSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final notifier = UserEditDraftScope.of(context);
    return Column(
      spacing: PauzaSpacing.small,
      children: <Widget>[
        InkWell(
          onTap: () => _onChangePhotoPressed(context),
          child: ProfileEditDraftAvatar(
            imageUrl: notifier.value.profilePictureUrl,
            imageBytes: notifier.value.profilePictureBytes,
            radius: 90,
          ),
        ),
        PauzaTextButton(
          onPressed: () => _onChangePhotoPressed(context),
          size: PauzaButtonSize.large,
          title: Text(l10n.profileEditChangePhoto),
        ),
      ],
    );
  }

  Future<void> _onChangePhotoPressed(BuildContext context) async {
    final source = await ProfilePhotoActionSheet.show(context);
    if (!context.mounted || source == null) {
      return;
    }

    final file = await ImagePicker().pickImage(source: source);
    if (file == null) {
      return;
    }

    final bytes = await file.readAsBytes();
    if (!context.mounted) {
      return;
    }

    UserEditDraftScope.of(
      context,
      watch: false,
    ).update(profilePictureBytes: bytes);
  }
}
