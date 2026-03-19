import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/app/root_scope.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/friends/friends_list/bloc/friends_list_bloc.dart';
import 'package:pauza/src/features/friends/friends_list/widget/friends_list_content.dart';
import 'package:pauza/src/features/subscription/widget/premium_gate.dart';
import 'package:pauza/src/features/subscription/widget/premium_locked_view.dart';

class FriendsListScreen extends StatelessWidget {
  const FriendsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return PremiumGate(
      lockedChild: PremiumLockedView(
        featureTitle: l10n.friendsTitle,
        featureDescription: l10n.premiumFriendsDescription,
      ),
      child: BlocProvider(
        create: (context) =>
            FriendsListBloc(friendsRepository: RootScope.of(context).friendsRepository)
              ..add(const FriendsListLoadRequested()),
        child: const FriendsListContent(),
      ),
    );
  }
}
