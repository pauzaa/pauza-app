import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helm/helm.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/core/routing/pauza_routes.dart';
import 'package:pauza/src/features/friends/friends_list/bloc/friends_list_bloc.dart';
import 'package:pauza/src/features/friends/friends_list/widget/friend_card.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class FriendsListContent extends StatelessWidget {
  const FriendsListContent({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.friendsTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            onPressed: () => HelmRouter.push(context, PauzaRoutes.findAndRequests, rootNavigator: true),
          ),
        ],
      ),
      body: BlocBuilder<FriendsListBloc, FriendsListState>(
        builder: (context, state) {
          if (state.isLoading && state.friends.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null && state.friends.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.friendsErrorTitle, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  PauzaFilledButton(
                    title: Text(l10n.friendsRetryButton),
                    onPressed: () => context.read<FriendsListBloc>().add(const FriendsListRefreshRequested()),
                  ),
                ],
              ),
            );
          }

          final filtered = state.filteredFriends;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<FriendsListBloc>().add(const FriendsListRefreshRequested());
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: PauzaTextFormField(
                      decoration: PauzaInputDecoration(
                        hintText: l10n.friendsSearchHint,
                        prefixIcon: const Icon(Icons.search_rounded),
                      ),
                      onChanged: (query) => context.read<FriendsListBloc>().add(FriendsListSearchChanged(query)),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.friendsActiveStreaks,
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium?.copyWith(color: context.pauzaColorScheme.onSurfaceVariant),
                        ),
                        Text(
                          l10n.friendsOnlineCount(state.friends.length),
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium?.copyWith(color: context.pauzaColorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
                if (filtered.isEmpty && !state.isLoading)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        l10n.friendsEmptyState,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: context.pauzaColorScheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  SliverList.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final friend = filtered[index];
                      return FriendCard(friend: friend, stats: state.friendStats[friend.friendshipId]);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
