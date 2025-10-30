import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AppThemeState extends Equatable {
  // We will store the current theme (light or dark)
  final ThemeMode themeMode;

  const AppThemeState({this.themeMode = ThemeMode.light});

  @override
  List<Object> get props => [themeMode];

  // A helper method to copy the state with a new theme
  AppThemeState copyWith({ThemeMode? themeMode}) {
    return AppThemeState(themeMode: themeMode ?? this.themeMode);
  }
}
