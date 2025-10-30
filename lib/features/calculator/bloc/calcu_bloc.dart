import 'package:all_in_one_app/features/calculator/bloc/calcu_event.dart';
import 'package:all_in_one_app/features/calculator/bloc/calcu_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CalculatorBloc extends Bloc<CalculatorEvent, CalculatorState> {
  // --- This is the internal "memory" of our calculator ---

  // The number that was entered *before* an operator
  String _firstOperand = '0';

  // The operator (+, -, *, /) that was pressed
  String _operator = '';

  // The value currently being shown on the display
  String _currentDisplay = '0';

  // A flag to know if we are currently typing a new number
  // (e.g., after pressing '+', the next number should start fresh)
  bool _isTypingNumber = false;

  // --------------------------------------------------------

  CalculatorBloc() : super(const CalculatorState(displayValue: '0')) {
    // Register all our event handlers
    on<ClearPressed>(_onClearPressed);
    on<NumberPressed>(_onNumberPressed);
    on<DecimalPressed>(_onDecimalPressed);
    on<OperatorPressed>(_onOperatorPressed);
    on<CalculatePressed>(_onCalculatePressed);
  }

  /// 'C' - Resets everything to its default state.
  void _onClearPressed(ClearPressed event, Emitter<CalculatorState> emit) {
    _firstOperand = '0';
    _operator = '';
    _currentDisplay = '0';
    _isTypingNumber = false;
    emit(const CalculatorState(displayValue: '0'));
  }

  /// '0-9' - Handles when a number is pressed.
  void _onNumberPressed(NumberPressed event, Emitter<CalculatorState> emit) {
    if (_currentDisplay == 'Error') {
      // Start over if we're in an error state
      _onClearPressed(ClearPressed(), emit);
      return;
    }

    if (_isTypingNumber) {
      // We are already typing a number, so append to it
      if (_currentDisplay == '0') {
        _currentDisplay = event.number;
      } else {
        _currentDisplay = _currentDisplay + event.number;
      }
    } else {
      // This is the first digit of a new number
      _currentDisplay = event.number;
      _isTypingNumber = true;
    }

    emit(CalculatorState(displayValue: _currentDisplay));
  }

  /// '.' - Handles when the decimal point is pressed.
  void _onDecimalPressed(DecimalPressed event, Emitter<CalculatorState> emit) {
    if (_currentDisplay == 'Error') return;

    if (_isTypingNumber) {
      // Only add a decimal if one doesn't already exist
      if (!_currentDisplay.contains('.')) {
        _currentDisplay = '$_currentDisplay.';
      }
    } else {
      // Start a new number with '0.'
      _currentDisplay = '0.';
      _isTypingNumber = true;
    }

    emit(CalculatorState(displayValue: _currentDisplay));
  }

  /// '+, -, *, /' - Handles when an operator is pressed.
  void _onOperatorPressed(
    OperatorPressed event,
    Emitter<CalculatorState> emit,
  ) {
    if (_currentDisplay == 'Error') return;

    // This handles chaining operations (e.g., "12 + 5 - 3")
    // If we have "12", "+", and "5" in memory and press "-",
    // we should first calculate "12 + 5".
    if (_isTypingNumber && _operator.isNotEmpty) {
      _calculate();
    }

    // Store the state for the next calculation
    _firstOperand = _currentDisplay;
    _operator = event.operator;
    _isTypingNumber = false; // The next number will be a new operand

    emit(CalculatorState(displayValue: _currentDisplay));
  }

  /// '=' - Handles when equals is pressed.
  void _onCalculatePressed(
    CalculatePressed event,
    Emitter<CalculatorState> emit,
  ) {
    if (_operator.isEmpty || !_isTypingNumber || _currentDisplay == 'Error') {
      // Not enough information to calculate
      return;
    }

    _calculate(); // Perform the calculation

    // Reset for the next operation
    _firstOperand =
        _currentDisplay; // The result becomes the next first operand
    _operator = '';
    _isTypingNumber = false;

    emit(CalculatorState(displayValue: _currentDisplay));
  }

  /// Internal helper function to perform the math.
  void _calculate() {
    try {
      final double num1 = double.parse(_firstOperand);
      final double num2 = double.parse(_currentDisplay);
      double result = 0;

      switch (_operator) {
        case '+':
          result = num1 + num2;
          break;
        case '-':
          result = num1 - num2;
          break;
        case '*':
          result = num1 * num2;
          break;
        case '/':
          if (num2 == 0) {
            // Handle divide by zero
            _currentDisplay = 'Error';
            _resetErrorState();
            return;
          }
          result = num1 / num2;
          break;
      }

      // Format the result (e.g., show "17" instead of "17.0")
      if (result == result.toInt()) {
        _currentDisplay = result.toInt().toString();
      } else {
        _currentDisplay = result.toString();
      }
    } catch (e) {
      _currentDisplay = 'Error';
      _resetErrorState();
    }
  }

  /// Resets internal state after an error.
  void _resetErrorState() {
    _firstOperand = '0';
    _operator = '';
    _isTypingNumber = false;
  }
}
