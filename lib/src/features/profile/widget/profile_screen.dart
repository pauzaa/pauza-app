import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/profile/common/bloc/current_user_state.dart';
import 'package:pauza/src/features/profile/common/bloc/current_user_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<CurrentUserBloc, CurrentUserState>(
      bloc: RootScope.of(context).currentUserBloc,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(l10n.profileTitle)),
          body: Center(
            child: _buildStateBody(state: state, l10n: l10n),
          ),
        );
      },
    );
  }

  Widget _buildStateBody({
    required CurrentUserState state,
    required AppLocalizations l10n,
  }) {
    return switch (state.status) {
      CurrentUserStatus.available => Text(
        '${state.user?.name ?? ''} (@${state.user?.username ?? ''}) ${state.freshness.name}${state.isSyncing ? ' • ${l10n.loadingLabel}' : ''}',
        textAlign: TextAlign.center,
      ),
      CurrentUserStatus.loading => Text(l10n.loadingLabel),
      CurrentUserStatus.unavailable => Text(l10n.emptyStateMessage),
      CurrentUserStatus.error => Text(l10n.errorTitle),
      CurrentUserStatus.unauthenticated => Text(l10n.emptyStateMessage),
    };
  }
}
