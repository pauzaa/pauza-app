part of 'ai_addiction_check_bloc.dart';

sealed class AiAddictionCheckEvent {
  const AiAddictionCheckEvent();
}

final class AiAddictionCheckRequested extends AiAddictionCheckEvent {
  const AiAddictionCheckRequested();
}
