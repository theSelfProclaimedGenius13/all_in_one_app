import 'package:equatable/equatable.dart';

abstract class CalculatorEvent extends Equatable {
  const CalculatorEvent();

  @override
  List<Object> get props => [];
}

// Event for when a number (0-9) is pressed
class NumberPressed extends CalculatorEvent {
  final String number;
  const NumberPressed(this.number);
  @override
  List<Object> get props => [number];
}

// Event for when an operator (+, -, *, /) is pressed
class OperatorPressed extends CalculatorEvent {
  final String operator;
  const OperatorPressed(this.operator);
  @override
  List<Object> get props => [operator];
}

// Event for when the decimal point (.) is pressed
class DecimalPressed extends CalculatorEvent {}

// Event for when 'C' (Clear) is pressed
class ClearPressed extends CalculatorEvent {}

// Event for when '=' (Equals) is pressed
class CalculatePressed extends CalculatorEvent {}
