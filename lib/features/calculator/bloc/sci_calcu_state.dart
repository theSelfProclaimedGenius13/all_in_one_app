import 'package:equatable/equatable.dart';

class ScientificCalculatorState extends Equatable {
  // The expression shown on the calculator display
  final String displayValue;

  const ScientificCalculatorState({this.displayValue = '0'});

  @override
  List<Object?> get props => [displayValue];

  ScientificCalculatorState copyWith({String? displayValue}) {
    return ScientificCalculatorState(
      displayValue: displayValue ?? this.displayValue,
    );
  }
}
