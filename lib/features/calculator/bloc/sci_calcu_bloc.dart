import 'package:all_in_one_app/features/calculator/bloc/sci_calcu_event.dart';
import 'package:all_in_one_app/features/calculator/bloc/sci_calcu_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_expressions/math_expressions.dart';

class ScientificCalculatorBloc
    extends Bloc<ScientificCalculatorEvent, ScientificCalculatorState> {
  ScientificCalculatorBloc()
    : super(const ScientificCalculatorState(displayValue: '0')) {
    // Register all our event handlers
    on<ButtonPressed>(_onButtonPressed);
    on<ClearPressed>(_onClearPressed);
    on<BackspacePressed>(_onBackspacePressed);
    on<CalculatePressed>(_onCalculatePressed);
  }

  /// 'C' - Resets the display to '0'.
  void _onClearPressed(
    ClearPressed event,
    Emitter<ScientificCalculatorState> emit,
  ) {
    emit(state.copyWith(displayValue: '0'));
  }

  /// '⌫' - Handles when backspace is pressed.
  void _onBackspacePressed(
    BackspacePressed event,
    Emitter<ScientificCalculatorState> emit,
  ) {
    final currentDisplay = state.displayValue;

    if (currentDisplay == 'Error' || currentDisplay == '0') {
      // Do nothing
    } else if (currentDisplay.length == 1) {
      // If only one digit left, reset to '0'
      emit(state.copyWith(displayValue: '0'));
    } else {
      // Remove the last character
      emit(
        state.copyWith(
          displayValue: currentDisplay.substring(0, currentDisplay.length - 1),
        ),
      );
    }
  }

  /// Handles when any button (number, operator, bracket) is pressed.
  void _onButtonPressed(
    ButtonPressed event,
    Emitter<ScientificCalculatorState> emit,
  ) {
    final currentDisplay = state.displayValue;
    final value = event.value;

    if (currentDisplay == '0' || currentDisplay == 'Error') {
      // Start a new expression
      emit(state.copyWith(displayValue: value));
    } else {
      // Append the new value to the existing expression
      emit(state.copyWith(displayValue: currentDisplay + value));
    }
  }

  /// '=' - Handles when equals is pressed.
  void _onCalculatePressed(
    CalculatePressed event,
    Emitter<ScientificCalculatorState> emit,
  ) {
    String expression = state.displayValue;
    if (expression == 'Error') return;

    // The 'math_expressions' package uses 'x' for multiplication,
    // but users might press '*'. Let's replace it.
    expression = expression.replaceAll('*', '*');
    expression = expression.replaceAll('^', '^');
    // You can add more replacements here if your buttons use different symbols
    // e.g., expression = expression.replaceAll('÷', '/');

    try {
      // --- 1. THIS IS THE NEW, NON-DEPRECATED CODE ---
      // Create a parser
      final ShuntingYardParser p = ShuntingYardParser();
      // Parse the expression
      final Expression exp = p.parse(expression);
      // Create a context model
      final ContextModel cm = ContextModel();
      // Evaluate the expression using RealEvaluator
      final double result = exp.evaluate(EvaluationType.REAL, cm);
      // --- END OF NEW CODE ---

      // 4. Format the result
      String resultString;
      if (result == result.toInt()) {
        resultString = result.toInt().toString(); // "17.0" -> "17"
      } else {
        resultString = result.toString(); // "17.5"
      }

      emit(state.copyWith(displayValue: resultString));
    } catch (e) {
      // If the expression is invalid (e.g., "1++2"), show an error
      emit(state.copyWith(displayValue: 'Error'));
    }
  }
}
