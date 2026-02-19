import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pauza/src/core/common/validation.dart';
import 'package:pauza/src/features/profile/data/user_profile_repository.dart';
import 'package:rxdart/rxdart.dart';

sealed class UserNameCheckerEvent extends Equatable {
  const UserNameCheckerEvent();
}

enum UsernameAvailability { unknown, checking, available, taken, error }

final class UserNameCheckerStarted extends UserNameCheckerEvent {
  const UserNameCheckerStarted({required this.username});

  final String username;

  @override
  List<Object?> get props => [username];
}

class UserNameCheckerBloc extends Bloc<UserNameCheckerEvent, UsernameAvailability> {
  UserNameCheckerBloc({required UserProfileRepository userProfileRepository, Duration debounceDuration = const Duration(milliseconds: 500)})
    : _userProfileRepository = userProfileRepository,
      super(UsernameAvailability.unknown) {
    on<UserNameCheckerStarted>(_onStarted, transformer: (events, mapper) => events.debounceTime(debounceDuration).switchMap(mapper));
  }

  final UserProfileRepository _userProfileRepository;

  Future<void> _onStarted(UserNameCheckerStarted event, Emitter<UsernameAvailability> emit) async {
    try {
      if (!PauzaValidators.isUsernameValid(event.username)) {
        emit(UsernameAvailability.error);
        return;
      }
      emit(UsernameAvailability.checking);
      final available = await _userProfileRepository.isUsernameAvailable(username: event.username);
      if (available) {
        emit(UsernameAvailability.available);
      } else {
        emit(UsernameAvailability.taken);
      }
    } on Object {
      emit(UsernameAvailability.error);
    }
  }
}
