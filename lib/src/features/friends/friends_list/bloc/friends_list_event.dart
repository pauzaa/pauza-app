part of 'friends_list_bloc.dart';

sealed class FriendsListEvent extends Equatable {
  const FriendsListEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class FriendsListLoadRequested extends FriendsListEvent {
  const FriendsListLoadRequested();
}

final class FriendsListSearchChanged extends FriendsListEvent {
  const FriendsListSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}

final class FriendsListRefreshRequested extends FriendsListEvent {
  const FriendsListRefreshRequested();
}
