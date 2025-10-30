import 'package:equatable/equatable.dart';

enum PomodoroStatus { timer_ready, timer_running, timer_paused, timer_break }

class PomodoroState extends Equatable {
  // The number of seconds left on the timer
  final int duration;

  // The current status (ready, running, etc.)
  final PomodoroStatus status;
  final int workDurationSetting;

  const PomodoroState({
    required this.duration, // Default to 25 minutes
    this.status = PomodoroStatus.timer_ready,
    this.workDurationSetting = 25 * 60,
  });

  @override
  List<Object> get props => [duration, status, workDurationSetting];

  PomodoroState copyWith({
    int? duration,
    PomodoroStatus? status,
    int? workDurationSetting,
  }) {
    return PomodoroState(
      duration: duration ?? this.duration,
      status: status ?? this.status,
      workDurationSetting: workDurationSetting ?? this.workDurationSetting,
    );
  }
}
