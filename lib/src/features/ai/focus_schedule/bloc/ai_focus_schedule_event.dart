part of 'ai_focus_schedule_bloc.dart';

sealed class AiFocusScheduleEvent {
  const AiFocusScheduleEvent();
}

final class AiFocusScheduleRequested extends AiFocusScheduleEvent {
  const AiFocusScheduleRequested();
}
