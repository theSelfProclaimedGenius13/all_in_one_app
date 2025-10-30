import 'package:all_in_one_app/features/pomodoro/bloc/pomodoro_bloc.dart';
import 'package:all_in_one_app/features/pomodoro/bloc/pomodoro_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/pomodoro_event.dart';

/// --- 1. The Main Widget (Provides the BLoC) ---
/// This widget creates and provides the PomodoroBloc to its child, `_PomodoroView`.
class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PomodoroBloc(),
      child: const _PomodoroView(),
    );
  }
}

/// --- 2. The View Widget (Builds the UI) ---
class _PomodoroView extends StatelessWidget {
  const _PomodoroView();

  // Helper function to format seconds into MM:SS
  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Note: No AppBar, this screen is part of the ShellRoute
      body: BlocBuilder<PomodoroBloc, PomodoroState>(
        builder: (context, state) {
          // Determine the background color based on the state
          Color backgroundColor = switch (state.status) {
            PomodoroStatus.timer_running => Colors.red.shade100,
            PomodoroStatus.timer_break => Colors.green.shade100,
            _ => Colors.white,
          };

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            color: backgroundColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- Timer Display ---
                Text(
                  _formatDuration(state.duration),
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 20),

                // --- Status Text ---
                Text(
                  _getStatusText(state.status),
                  style: TextStyle(fontSize: 24, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
                _buildDurationControls(context, state),
                const SizedBox(height: 40),
                // --- Action Buttons ---
                _buildActionButtons(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Helper to get a display string for the current status
  String _getStatusText(PomodoroStatus status) {
    switch (status) {
      case PomodoroStatus.timer_running:
        return 'Work';
      case PomodoroStatus.timer_break:
        return 'Break';
      case PomodoroStatus.timer_paused:
        return 'Paused';
      case PomodoroStatus.timer_ready:
        return 'Ready to start?';
    }
  }

  /// Helper widget to build the correct action buttons
  Widget _buildActionButtons(BuildContext context, PomodoroState state) {
    final bloc = context.read<PomodoroBloc>();

    // We use a Row with MainAxisAlignment.center to hold the buttons
    Row buttons;

    switch (state.status) {
      case PomodoroStatus.timer_ready:
        buttons = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PomodoroButton(
              icon: Icons.play_arrow,
              label: 'START',
              onPressed: () => bloc.add(StartTimer()),
            ),
          ],
        );
        break;

      case PomodoroStatus.timer_running:
      case PomodoroStatus.timer_break:
        buttons = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PomodoroButton(
              icon: Icons.pause,
              label: 'PAUSE',
              onPressed: () => bloc.add(PauseTimer()),
            ),
            const SizedBox(width: 20),
            _PomodoroButton(
              icon: Icons.stop,
              label: 'STOP',
              onPressed: () => bloc.add(StopTimer()),
            ),
          ],
        );
        break;

      case PomodoroStatus.timer_paused:
        buttons = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PomodoroButton(
              icon: Icons.play_arrow,
              label: 'RESUME',
              onPressed: () => bloc.add(ResumeTimer()),
            ),
            const SizedBox(width: 20),
            _PomodoroButton(
              icon: Icons.stop,
              label: 'STOP',
              onPressed: () => bloc.add(StopTimer()),
            ),
          ],
        );
        break;
    }

    // This ensures the buttons don't "jump" when changing
    return SizedBox(height: 60, child: buttons);
  }
}

Widget _buildDurationControls(BuildContext context, PomodoroState state) {
  // Only show controls when the timer is 'Ready'
  if (state.status != PomodoroStatus.timer_ready) {
    // Return an empty box to maintain layout
    return const SizedBox(height: 60);
  }

  final bloc = context.read<PomodoroBloc>();
  // Get current setting in minutes
  final currentMinutes = state.workDurationSetting ~/ 60;

  return SizedBox(
    height: 60, // Give it a fixed height
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          iconSize: 30,
          color: Colors.grey.shade700,
          // Don't allow going below 5 minutes
          onPressed: currentMinutes <= 5
              ? null
              : () {
                  bloc.add(ChangeDuration(currentMinutes - 5));
                },
        ),
        Text(
          '$currentMinutes min',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          iconSize: 30,
          color: Colors.grey.shade700,
          // Don't allow going above 60 minutes
          onPressed: currentMinutes >= 60
              ? null
              : () {
                  bloc.add(ChangeDuration(currentMinutes + 5));
                },
        ),
      ],
    ),
  );
}

/// --- 3. A Helper Widget for the Buttons ---
class _PomodoroButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _PomodoroButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        textStyle: const TextStyle(fontSize: 16),
        backgroundColor: Colors.grey.shade800,
        foregroundColor: Colors.white,
      ),
    );
  }
}
