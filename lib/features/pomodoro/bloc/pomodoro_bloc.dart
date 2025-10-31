import 'dart:async';

import 'package:all_in_one_app/features/pomodoro/bloc/pomodoro_event.dart';
import 'package:all_in_one_app/features/pomodoro/bloc/pomodoro_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:all_in_one_app/features/pomodoro/notification_services.dart';

class PomodoroBloc extends Bloc<PomodoroEvent, PomodoroState> {
  // --- Timer Settings ---

  static const int _breakDuration = 5 * 60; // 5 minutes
  static const int _defaultWorkDuration = 25 * 60;

  // --- Internal Timer ---
  // This will hold our active 1-second timer
  Timer? _timer;
  final NotificationService _notificationService;

  PomodoroBloc({required NotificationService notificationService})
    : _notificationService = notificationService,
      super(
        const PomodoroState(
          duration: _defaultWorkDuration,
          workDurationSetting: _defaultWorkDuration,
        ),
      ) {
    // Register all our event handlers
    on<StartTimer>(_onStartTimer);
    on<PauseTimer>(_onPauseTimer);
    on<ResumeTimer>(_onResumeTimer);
    on<StopTimer>(_onStopTimer);
    on<TickTimer>(_onTickTimer);
    on<ChangeDuration>(_onChangeDuration);
  }

  /// This is called when the BLoC is closed (e.g., user leaves the screen).
  /// It's VITAL to cancel the timer to prevent memory leaks.
  @override
  Future<void> close() {
    _timer?.cancel(); // Cancel any active timer
    return super.close();
  }

  /// --- Event Handlers ---
  void _onChangeDuration(ChangeDuration event, Emitter<PomodoroState> emit) {
    // We only allow changing the duration when the timer is 'Ready'
    if (state.status == PomodoroStatus.timer_ready) {
      final newDurationInSeconds = event.newDurationInMinutes * 60;
      emit(
        state.copyWith(
          workDurationSetting: newDurationInSeconds,
          duration: newDurationInSeconds, // Update the display too
        ),
      );
    }
  }

  /// User presses "Start"
  void _onStartTimer(StartTimer event, Emitter<PomodoroState> emit) {
    _timer?.cancel(); // Cancel any existing timer

    // Emit the 'Running' state with the full work duration
    emit(
      state.copyWith(
        duration: state.workDurationSetting,
        status: PomodoroStatus.timer_running,
      ),
    );

    // Start a new 1-second periodic timer
    // Every 1 second, it will add a 'TickTimer' event
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(TickTimer(state.duration - 1));
    });
  }

  /// User presses "Pause"
  void _onPauseTimer(PauseTimer event, Emitter<PomodoroState> emit) {
    if (state.status == PomodoroStatus.timer_running) {
      _timer?.cancel(); // Stop the timer
      emit(
        state.copyWith(status: PomodoroStatus.timer_paused),
      ); // Emit 'Paused' state
    }
  }

  /// User presses "Resume" (from a paused state)
  void _onResumeTimer(ResumeTimer event, Emitter<PomodoroState> emit) {
    if (state.status == PomodoroStatus.timer_paused) {
      // Re-start the timer (it will pick up from the current duration)
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        add(TickTimer(state.duration - 1));
      });
      emit(
        state.copyWith(status: PomodoroStatus.timer_running),
      ); // Emit 'Running' state
    }
  }

  /// User presses "Stop" or the cycle completes
  void _onStopTimer(StopTimer event, Emitter<PomodoroState> emit) {
    _timer?.cancel();
    // Reset to the 'Ready' state with the full work duration
    emit(
      state.copyWith(
        duration: state.workDurationSetting,
        status: PomodoroStatus.timer_ready,
      ),
    );
  }

  /// This event is sent by our BLoC *to itself* every second.
  void _onTickTimer(TickTimer event, Emitter<PomodoroState> emit) {
    if (event.duration > 0) {
      // If time is left, just update the duration
      emit(state.copyWith(duration: event.duration));
    } else {
      // --- Timer has finished ---
      _timer?.cancel(); // Stop the current timer

      if (state.status == PomodoroStatus.timer_running) {
        // --- Work session finished, start a break ---
        emit(
          state.copyWith(
            duration: _breakDuration,
            status: PomodoroStatus.timer_break,
          ),
        );
        _notificationService.showNotification(
          "Time for a break!",
          "Great work! Your 5-minute break has started.",
        );
        // Automatically start the break timer
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          add(TickTimer(state.duration - 1));
        });
      } else if (state.status == PomodoroStatus.timer_break) {
        // --- Break session finished, reset to 'Ready' ---
        emit(
          state.copyWith(
            duration: state.workDurationSetting,
            status: PomodoroStatus.timer_ready,
          ),
        );
        _notificationService.showNotification(
          "Break's over!",
          "Your next work session is ready to start.",
        );
      }
    }
  }
}
