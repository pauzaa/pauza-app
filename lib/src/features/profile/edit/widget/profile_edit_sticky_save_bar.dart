import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/profile/common/model/user_dto.dart';
import 'package:pauza/src/features/profile/edit/bloc/profile_edit_bloc.dart';
import 'package:pauza/src/features/profile/edit/bloc/user_name_checker_bloc.dart';
import 'package:pauza/src/features/profile/edit/domain/user_edit_draft_notifier.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class ProfileEditSaveButton extends StatelessWidget {
  const ProfileEditSaveButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(PauzaSpacing.medium, PauzaSpacing.medium, PauzaSpacing.medium, PauzaSpacing.medium),
      child: BlocBuilder<UserNameCheckerBloc, UsernameAvailability>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, usernameAvailability) {
          return BlocSelector<ProfileEditBloc, ProfileEditState, UserDto?>(
            selector: (state) {
              switch (state) {
                case ProfileEditReady():
                  return state.user;
                case ProfileEditInitial():
                case ProfileEditLoading():
                case ProfileEditSaving():
                case ProfileEditSuccess():
                case ProfileEditFailure():
                  return null;
              }
            },
            builder: (context, state) {
              return PauzaFilledButton(
                onPressed: () {
                  if (Form.of(context).validate()) {
                    final notifier = UserEditDraftScope.of(context, watch: false);

                    context.read<ProfileEditBloc>().add(
                      ProfileEditSaveRequested(
                        name: notifier.value.name,
                        username: notifier.value.username,
                        profilePictureUrl: notifier.value.profilePictureUrl,
                        profilePictureBytes: notifier.value.profilePictureBytes,
                      ),
                    );
                  }
                },
                disabled:
                    state == null ||
                    !UserEditDraftScope.of(context).canSubmit(state) ||
                    usernameAvailability == UsernameAvailability.checking ||
                    usernameAvailability == UsernameAvailability.taken,
                title: Text(context.l10n.profileEditSaveButton),
                size: PauzaButtonSize.large,
              );
            },
          );
        },
      ),
    );
  }
}
