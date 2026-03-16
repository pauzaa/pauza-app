part of 'find_and_requests_bloc.dart';

final class FindAndRequestsState extends Equatable {
  const FindAndRequestsState({
    required this.isLoading,
    required this.incomingRequests,
    required this.outgoingRequests,
    required this.searchQuery,
    required this.searchResults,
    required this.isSearching,
    required this.actionInProgress,
    this.error,
  });

  const FindAndRequestsState.initial()
    : this(
        isLoading: false,
        incomingRequests: const <FriendRequestDto>[],
        outgoingRequests: const <FriendRequestDto>[],
        searchQuery: '',
        searchResults: const <BasicUserDto>[],
        isSearching: false,
        actionInProgress: const <String>{},
      );

  final bool isLoading;
  final List<FriendRequestDto> incomingRequests;
  final List<FriendRequestDto> outgoingRequests;
  final String searchQuery;
  final List<BasicUserDto> searchResults;
  final bool isSearching;
  final Set<String> actionInProgress;
  final Object? error;

  int get totalRequestCount => incomingRequests.length + outgoingRequests.length;

  FindAndRequestsState copyWith({
    bool? isLoading,
    List<FriendRequestDto>? incomingRequests,
    List<FriendRequestDto>? outgoingRequests,
    String? searchQuery,
    List<BasicUserDto>? searchResults,
    bool? isSearching,
    Set<String>? actionInProgress,
    Object? error,
    bool clearError = false,
  }) {
    return FindAndRequestsState(
      isLoading: isLoading ?? this.isLoading,
      incomingRequests: incomingRequests ?? this.incomingRequests,
      outgoingRequests: outgoingRequests ?? this.outgoingRequests,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      actionInProgress: actionInProgress ?? this.actionInProgress,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    isLoading,
    incomingRequests,
    outgoingRequests,
    searchQuery,
    searchResults,
    isSearching,
    actionInProgress,
    error,
  ];
}
