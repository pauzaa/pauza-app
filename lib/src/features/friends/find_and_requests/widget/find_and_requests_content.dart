import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/localization/l10n.dart';
import 'package:pauza/src/features/friends/find_and_requests/bloc/find_and_requests_bloc.dart';
import 'package:pauza/src/features/friends/find_and_requests/widget/pending_request_card.dart';
import 'package:pauza/src/features/friends/find_and_requests/widget/search_result_tile.dart';
import 'package:pauza_ui_kit/pauza_ui_kit.dart';

class FindAndRequestsContent extends StatelessWidget {
  const FindAndRequestsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.findAndRequestsTitle), centerTitle: true),
      body: BlocBuilder<FindAndRequestsBloc, FindAndRequestsState>(
        builder: (context, state) {
          if (state.isLoading && state.incomingRequests.isEmpty && state.outgoingRequests.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null && state.incomingRequests.isEmpty && state.outgoingRequests.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.findAndRequestsErrorTitle, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  PauzaFilledButton(
                    title: Text(l10n.friendsRetryButton),
                    onPressed: () => context.read<FindAndRequestsBloc>().add(const FindAndRequestsLoadRequested()),
                  ),
                ],
              ),
            );
          }

          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: PauzaTextFormField(
                  decoration: PauzaInputDecoration(
                    hintText: l10n.findAndRequestsSearchHint,
                    prefixIcon: const Icon(Icons.search_rounded),
                  ),
                  onChanged: (query) => context.read<FindAndRequestsBloc>().add(FindAndRequestsSearchChanged(query)),
                ),
              ),
              if (state.totalRequestCount > 0) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        l10n.findAndRequestsPendingRequests,
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(color: context.pauzaColorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.pauzaColorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          l10n.findAndRequestsTotalBadge(state.totalRequestCount),
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(color: context.pauzaColorScheme.onPrimaryContainer),
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.incomingRequests.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      l10n.findAndRequestsIncoming,
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: context.pauzaColorScheme.onSurfaceVariant),
                    ),
                  ),
                  ...state.incomingRequests.map(
                    (r) => PendingRequestCard(
                      request: r,
                      isIncoming: true,
                      isActionInProgress: state.actionInProgress.contains(r.friendshipId),
                      onAccept: () => context.read<FindAndRequestsBloc>().add(FindAndRequestsAccepted(r.friendshipId)),
                      onDecline: () => context.read<FindAndRequestsBloc>().add(FindAndRequestsDeclined(r.friendshipId)),
                    ),
                  ),
                ],
                if (state.outgoingRequests.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      l10n.findAndRequestsOutgoing,
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: context.pauzaColorScheme.onSurfaceVariant),
                    ),
                  ),
                  ...state.outgoingRequests.map(
                    (r) => PendingRequestCard(
                      request: r,
                      isIncoming: false,
                      isActionInProgress: state.actionInProgress.contains(r.friendshipId),
                      onCancel: () => context.read<FindAndRequestsBloc>().add(FindAndRequestsCancelled(r.friendshipId)),
                    ),
                  ),
                ],
              ],
              if (state.searchQuery.isNotEmpty) ...[
                const SizedBox(height: 16),
                if (state.isSearching)
                  const Center(
                    child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
                  )
                else if (state.searchResults.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        l10n.findAndRequestsNoResults,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: context.pauzaColorScheme.onSurfaceVariant),
                      ),
                    ),
                  )
                else
                  ...state.searchResults.map(
                    (user) => SearchResultTile(
                      user: user,
                      isActionInProgress: state.actionInProgress.contains(user.username),
                      onAdd: () => context.read<FindAndRequestsBloc>().add(FindAndRequestsSendRequest(user.username)),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
