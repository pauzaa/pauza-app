import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/common_ui/pauza_toast.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/profile/edit/bloc/profile_edit_bloc.dart';
import 'package:pauza/src/features/profile/edit/domain/user_edit_draft_notifier.dart';
import 'package:pauza/src/features/profile/edit/widget/profile_edit_avatar_section.dart';
import 'package:pauza/src/features/profile/edit/widget/profile_edit_form.dart';
import 'package:pauza/src/features/profile/edit/widget/profile_edit_sticky_save_bar.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class ProfileEditBody extends StatelessWidget {
  const ProfileEditBody({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocListener<ProfileEditBloc, ProfileEditState>(
      listener: (context, state) {
        switch (state) {
          case ProfileEditSuccess():
            if (context.mounted) {
              Navigator.of(context).pop();
            }
            return;
          case ProfileEditFailure():
            if (context.mounted) {
              context.showToast(state.failureCode.localize(l10n));
            }
            return;
          case ProfileEditInitial():
          case ProfileEditLoading():
          case ProfileEditSaving():
            break;
          case ProfileEditReady():
            UserEditDraftScope.of(context).replace(state.user);
        }
      },
      child: Form(
        child: Scaffold(
          appBar: AppBar(title: Text(l10n.profileEditTitle)),
          bottomNavigationBar: const ProfileEditSaveButton(),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: PauzaSpacing.medium,
              vertical: PauzaSpacing.large,
            ).copyWith(top: PauzaSpacing.giant),
            children: const <Widget>[
              ProfileEditAvatarSection(),
              SizedBox(height: PauzaSpacing.medium),
              ProfileEditForm(),
            ],
          ),
        ),
      ),
    );
  }
}
