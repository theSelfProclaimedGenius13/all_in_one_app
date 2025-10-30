import 'package:equatable/equatable.dart';

abstract class PomodoroEvent extends Equatable {
  const PomodoroEvent();

  @override
  List<Object> get props => [];
}

// User presses the "Start" button
class StartTimer extends PomodoroEvent {}

// User presses the "Pause" button
class PauseTimer extends PomodoroEvent {}

// User presses the "Resume" button
class ResumeTimer extends PomodoroEvent {}

// User presses the "Stop" button (or the timer finishes)
class StopTimer extends PomodoroEvent {}

// An internal event that the BLoC sends to itself every second
class TickTimer extends PomodoroEvent {
  final int duration;
  const TickTimer(this.duration);

  @override
  List<Object> get props => [duration];
}

class ChangeDuration extends PomodoroEvent {
  final int newDurationInMinutes;
  const ChangeDuration(this.newDurationInMinutes);

  @override
  List<Object> get props => [newDurationInMinutes];
}
