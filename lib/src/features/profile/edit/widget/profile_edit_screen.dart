import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/core/init/pauza_dependencies.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza/src/features/profile/edit/bloc/profile_edit_bloc.dart';
import 'package:pauza/src/features/profile/edit/bloc/user_name_checker_bloc.dart';
import 'package:pauza/src/features/profile/edit/domain/user_edit_draft_notifier.dart';
import 'package:pauza/src/features/profile/edit/widget/profile_edit_body.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  static void show(BuildContext context) {
    HelmRouter.push(context, PauzaRoutes.profileEdit);
  }

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final UserEditDraftNotifier _notifier;

  @override
  void initState() {
    _notifier = UserEditDraftNotifier();
    super.initState();
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = PauzaDependencies.of(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ProfileEditBloc(userProfileRepository: dependencies.userProfileRepository)..add(const ProfileEditStarted()),
        ),
        BlocProvider(create: (context) => UserNameCheckerBloc(userProfileRepository: dependencies.userProfileRepository)),
      ],
      child: UserEditDraftScope(notifier: _notifier, child: const ProfileEditBody()),
    );
  }
}
