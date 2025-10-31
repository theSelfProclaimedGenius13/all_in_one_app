import 'package:equatable/equatable.dart';

abstract class ScientificCalculatorEvent extends Equatable {
  const ScientificCalculatorEvent();

  @override
  List<Object?> get props => [];
}

// Event for when any button (number, operator, parenthesis) is pressed
class ButtonPressed extends ScientificCalculatorEvent {
  final String value;

  const ButtonPressed(this.value);

  @override
  List<Object?> get props => [value];
}

// Event for 'C' (Clear)
class ClearPressed extends ScientificCalculatorEvent {
  const ClearPressed();
}

// Event for '⌫' (Backspace)
class BackspacePressed extends ScientificCalculatorEvent {
  const BackspacePressed();
}

// Event for '=' (Equals)
class CalculatePressed extends ScientificCalculatorEvent {
  const CalculatePressed();
}
