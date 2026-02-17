import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/features/profile/common/bloc/current_user_bloc.dart';
import 'package:pauza/src/features/profile/common/bloc/current_user_state.dart';
import 'package:pauza/src/features/profile/widget/profile_content.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentUserBloc, CurrentUserState>(
      bloc: RootScope.of(context).currentUserBloc,
      builder: (context, state) {
        return ProfileContent(state: state);
      },
    );
  }
}
