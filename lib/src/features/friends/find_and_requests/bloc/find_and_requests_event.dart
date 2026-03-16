part of 'find_and_requests_bloc.dart';

sealed class FindAndRequestsEvent extends Equatable {
  const FindAndRequestsEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class FindAndRequestsLoadRequested extends FindAndRequestsEvent {
  const FindAndRequestsLoadRequested();
}

final class FindAndRequestsSearchChanged extends FindAndRequestsEvent {
  const FindAndRequestsSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}

final class FindAndRequestsAccepted extends FindAndRequestsEvent {
  const FindAndRequestsAccepted(this.friendshipId);

  final String friendshipId;

  @override
  List<Object?> get props => <Object?>[friendshipId];
}

final class FindAndRequestsDeclined extends FindAndRequestsEvent {
  const FindAndRequestsDeclined(this.friendshipId);

  final String friendshipId;

  @override
  List<Object?> get props => <Object?>[friendshipId];
}

final class FindAndRequestsCancelled extends FindAndRequestsEvent {
  const FindAndRequestsCancelled(this.friendshipId);

  final String friendshipId;

  @override
  List<Object?> get props => <Object?>[friendshipId];
}

final class FindAndRequestsSendRequest extends FindAndRequestsEvent {
  const FindAndRequestsSendRequest(this.username);

  final String username;

  @override
  List<Object?> get props => <Object?>[username];
}
