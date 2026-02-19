import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/profile/edit/bloc/user_name_checker_bloc.dart';
import 'package:pauza/src/features/profile/edit/domain/user_edit_draft_notifier.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class ProfileEditForm extends StatelessWidget {
  const ProfileEditForm({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = UserEditDraftScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: PauzaSpacing.medium,
      children: <Widget>[
        PauzaTextFormField(
          key: ValueKey<int>(notifier.revision),
          initialValue: notifier.value.name,
          textInputAction: TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) => notifier.validateName(context.l10n),
          onChanged: (value) => notifier.update(name: value),
          decoration: PauzaInputDecoration(
            labelText: context.l10n.profileEditNameLabel,
            hintText: context.l10n.profileEditNameHint,
            suffixIcon: const Icon(Icons.badge_rounded),
          ),
        ),
        BlocBuilder<UserNameCheckerBloc, UsernameAvailability>(
          buildWhen: (previous, current) => previous != current,
          builder: (context, state) {
            return PauzaTextFormField(
              key: ValueKey<int>(notifier.revision),
              initialValue: notifier.value.username,
              textInputAction: TextInputAction.done,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) => notifier.validateUsername(context.l10n, state),
              onChanged: (value) {
                notifier.update(username: value);

                context.read<UserNameCheckerBloc>().add(UserNameCheckerStarted(username: value));
              },
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9_]'))],
              decoration: PauzaInputDecoration(
                labelText: context.l10n.profileEditUsernameLabel,
                hintText: context.l10n.profileEditUsernameHint,
                prefixText: '@',
                suffixIcon: state == UsernameAvailability.checking
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, padding: EdgeInsets.all(12)))
                    : const Icon(Icons.alternate_email_rounded),
              ),
            );
          },
        ),
      ],
    );
  }
}
