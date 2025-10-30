import 'package:equatable/equatable.dart';

class CalculatorState extends Equatable {
  // The value shown on the calculator display
  final String displayValue;

  const CalculatorState({this.displayValue = '0'});

  @override
  List<Object> get props => [displayValue];

  CalculatorState copyWith({String? displayValue}) {
    return CalculatorState(displayValue: displayValue ?? this.displayValue);
  }
}
