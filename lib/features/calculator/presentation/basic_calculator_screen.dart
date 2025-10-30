import 'package:all_in_one_app/features/calculator/bloc/calcu_bloc.dart';
import 'package:all_in_one_app/features/calculator/bloc/calcu_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/calcu_event.dart';

/// --- 1. The Main Widget (Provides the BLoC) ---
/// This widget creates and provides the CalculatorBloc to its child, `_CalculatorView`.
class BasicCalculator extends StatelessWidget {
  const BasicCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CalculatorBloc(),
      child: const _CalculatorView(),
    );
  }
}

/// --- 2. The View Widget (Builds the UI) ---
/// This widget is separate so it can access the BLoC from its `context`.
class _CalculatorView extends StatelessWidget {
  const _CalculatorView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Note: No AppBar, this screen is part of the ShellRoute
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildDisplay(context), // The display area
            _buildButtonPad(context), // The grid of buttons
          ],
        ),
      ),
    );
  }

  /// Builds the display area that shows the current value.
  Widget _buildDisplay(BuildContext context) {
    return BlocBuilder<CalculatorBloc, CalculatorState>(
      builder: (context, state) {
        return Expanded(
          flex: 2, // Gives the display more space
          child: Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Text(
              state.displayValue,
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w300),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }

  /// Builds the grid of calculator buttons.
  Widget _buildButtonPad(BuildContext context) {
    final operatorColor = Colors.orange.shade700;
    final otherColor = Colors.grey.shade800;

    return Expanded(
      flex: 3, // Gives the buttons less space than the display
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CalculatorButton(
                  text: 'C',
                  color: otherColor,
                  onPressed: () =>
                      context.read<CalculatorBloc>().add(ClearPressed()),
                ),
                _CalculatorButton(
                  text: '/',
                  color: operatorColor,
                  onPressed: () =>
                      context.read<CalculatorBloc>().add(OperatorPressed('/')),
                ),
                _CalculatorButton(
                  text: '*',
                  color: operatorColor,
                  onPressed: () =>
                      context.read<CalculatorBloc>().add(OperatorPressed('*')),
                ),
                _CalculatorButton(
                  text: '-',
                  color: operatorColor,
                  onPressed: () =>
                      context.read<CalculatorBloc>().add(OperatorPressed('-')),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CalculatorButton(
                  text: '7',
                  onPressed: () =>
                      context.read<CalculatorBloc>().add(NumberPressed('7')),
                ),
                _CalculatorButton(
                  text: '8',
                  onPressed: () =>
                      context.read<CalculatorBloc>().add(NumberPressed('8')),
                ),
                _CalculatorButton(
                  text: '9',
                  onPressed: () =>
                      context.read<CalculatorBloc>().add(NumberPressed('9')),
                ),
                _CalculatorButton(
                  text: '+',
                  color: operatorColor,
                  onPressed: () =>
                      context.read<CalculatorBloc>().add(OperatorPressed('+')),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CalculatorButton(
                  text: '4',
                  onPressed: () =>
                      context.read<CalculatorBloc>().add(NumberPressed('4')),
                ),
                _CalculatorButton(
                  text: '5',
                  onPressed: () =>
                      context.read<CalculatorBloc>().add(NumberPressed('5')),
                ),
                _CalculatorButton(
                  text: '6',
                  onPressed: () =>
                      context.read<CalculatorBloc>().add(NumberPressed('6')),
                ),
                _CalculatorButton(
                  text: '=',
                  color: operatorColor,
                  onPressed: () =>
                      context.read<CalculatorBloc>().add(CalculatePressed()),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CalculatorButton(
                  text: '1',
                  onPressed: () =>
                      context.read<CalculatorBloc>().add(NumberPressed('1')),
                ),
                _CalculatorButton(
                  text: '2',
                  onPressed: () =>
                      context.read<CalculatorBloc>().add(NumberPressed('2')),
                ),
                _CalculatorButton(
                  text: '3.0', // Whoops, typo. Should be '3'
                  onPressed: () =>
                      context.read<CalculatorBloc>().add(NumberPressed('3')),
                ),
                _CalculatorButton(
                  text: '0',
                  flex: 2, // '0' button is wider
                  onPressed: () =>
                      context.read<CalculatorBloc>().add(NumberPressed('0')),
                ),
                _CalculatorButton(
                  text: '.',
                  onPressed: () =>
                      context.read<CalculatorBloc>().add(DecimalPressed()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// --- 3. The Helper Widget (For a single button) ---
/// This is a private helper to avoid repeating button code.
class _CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final int flex;
  final Color? color;

  const _CalculatorButton({
    required this.text,
    required this.onPressed,
    this.flex = 1,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.grey.shade600,
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            textStyle: const TextStyle(fontSize: 24),
          ),
          child: Text(text),
        ),
      ),
    );
  }
}
