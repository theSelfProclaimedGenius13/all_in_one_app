import 'package:equatable/equatable.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

// Event to load the saved theme from storage
class LoadTheme extends ThemeEvent {}

// Event to toggle the theme
class ToggleTheme extends ThemeEvent {}
