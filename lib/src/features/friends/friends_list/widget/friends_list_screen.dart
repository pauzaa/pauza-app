import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/core/connectivity/widget/internet_required_body.dart';
import 'package:pauza/src/core/init/pauza_dependencies.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/friends/friends_list/bloc/friends_list_bloc.dart';
import 'package:pauza/src/features/friends/friends_list/widget/friends_list_content.dart';

class FriendsListScreen extends StatelessWidget {
  const FriendsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocProvider(
      create: (context) =>
          FriendsListBloc(friendsRepository: RootScope.of(context).friendsRepository)
            ..add(const FriendsListLoadRequested()),
      child: InternetRequiredBody(
        gate: PauzaDependencies.of(context).internetHealthGate,
        offlineTitle: l10n.friendsOfflineTitle,
        offlineMessage: l10n.friendsOfflineMessage,
        offlineRetryButtonLabel: l10n.friendsRetryButton,
        child: const FriendsListContent(),
      ),
    );
  }
}
