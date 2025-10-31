import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/sci_calcu_bloc.dart';
import '../bloc/sci_calcu_event.dart';
import '../bloc/sci_calcu_state.dart';

class ScientificCalculator extends StatelessWidget {
  const ScientificCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScientificCalculatorBloc(),
      child: const _CalculatorView(),
    );
  }
}

/// --- 2. The View Widget (Builds the UI) ---
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

  /// Builds the display area that shows the current expression.
  Widget _buildDisplay(BuildContext context) {
    return BlocBuilder<ScientificCalculatorBloc, ScientificCalculatorState>(
      builder: (context, state) {
        return Expanded(
          flex: 2, // Give the display 2 parts of the space
          child: Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Text(
              state.displayValue,
              style: TextStyle(
                fontSize: state.displayValue.length > 10 ? 40 : 64,
                // Smaller font if long
                fontWeight: FontWeight.w300,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }

  /// Builds the 6x5 grid of calculator buttons.
  Widget _buildButtonPad(BuildContext context) {
    final operatorColor = Colors.orange.shade700;
    final otherColor = Colors.grey.shade800;

    // Helper function to send the ButtonPressed event
    void _onButtonPressed(String value) {
      context.read<ScientificCalculatorBloc>().add(ButtonPressed(value));
    }

    return Expanded(
      flex: 3, // Give the buttons 3 parts of the space
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CalculatorButton(
                  text: 'C',
                  color: otherColor,
                  onPressed: () => context.read<ScientificCalculatorBloc>().add(
                    ClearPressed(),
                  ),
                ),
                _CalculatorButton(
                  text: '(',
                  color: otherColor,
                  onPressed: () => _onButtonPressed('('),
                ),
                _CalculatorButton(
                  text: ')',
                  color: otherColor,
                  onPressed: () => _onButtonPressed(')'),
                ),
                _CalculatorButton(
                  text: '⌫', // Backspace
                  color: otherColor,
                  onPressed: () => context.read<ScientificCalculatorBloc>().add(
                    BackspacePressed(),
                  ),
                ),
                _CalculatorButton(
                  text: '/',
                  color: operatorColor,
                  onPressed: () => _onButtonPressed('/'),
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
                  onPressed: () => _onButtonPressed('7'),
                ),
                _CalculatorButton(
                  text: '8',
                  onPressed: () => _onButtonPressed('8'),
                ),
                _CalculatorButton(
                  text: '9',
                  onPressed: () => _onButtonPressed('9'),
                ),
                _CalculatorButton(
                  text: '^', // Power
                  color: operatorColor,
                  onPressed: () => _onButtonPressed('^'),
                ),
                _CalculatorButton(
                  text: '*',
                  color: operatorColor,
                  onPressed: () => _onButtonPressed('*'),
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
                  onPressed: () => _onButtonPressed('4'),
                ),
                _CalculatorButton(
                  text: '5',
                  onPressed: () => _onButtonPressed('5'),
                ),
                _CalculatorButton(
                  text: '6',
                  onPressed: () => _onButtonPressed('6'),
                ),
                _CalculatorButton(
                  text: '%', // Modulo
                  color: operatorColor,
                  onPressed: () => _onButtonPressed('%'),
                ),
                _CalculatorButton(
                  text: '-',
                  color: operatorColor,
                  onPressed: () => _onButtonPressed('-'),
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
                  onPressed: () => _onButtonPressed('1'),
                ),
                _CalculatorButton(
                  text: '2',
                  onPressed: () => _onButtonPressed('2'),
                ),
                _CalculatorButton(
                  text: '3',
                  onPressed: () => _onButtonPressed('3'),
                ),
                _CalculatorButton(
                  text: '+', // <-- HERE IS THE PLUS SIGN
                  color: operatorColor,
                  onPressed: () => _onButtonPressed('+'),
                ),
              ],
            ),
          ),

          // --- AND REPLACE THIS ROW ---
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CalculatorButton(
                  text: '0',
                  flex: 2, // '0' button is 2 units wide
                  onPressed: () => _onButtonPressed('0'),
                ),
                _CalculatorButton(
                  text: '.',
                  onPressed: () => _onButtonPressed('.'),
                ),
                _CalculatorButton(
                  text: '=',
                  color: operatorColor,
                  flex: 2, // '=' button is 2 units wide
                  onPressed: () => context.read<ScientificCalculatorBloc>().add(
                    CalculatePressed(),
                  ),
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
/// This is the same as the basic calculator's, just with a smaller font.
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
            textStyle: const TextStyle(fontSize: 20), // Smaller font
          ),
          child: Text(text),
        ),
      ),
    );
  }
}
