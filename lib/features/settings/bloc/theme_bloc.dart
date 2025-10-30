import 'package:all_in_one_app/features/settings/bloc/theme_event.dart';
import 'package:all_in_one_app/features/settings/bloc/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeBloc extends Bloc<ThemeEvent, AppThemeState> {
  // This is the key we'll use to save the theme in storage
  static const String _themeKey = 'theme';

  ThemeBloc() : super(const AppThemeState(themeMode: ThemeMode.light)) {
    // Register our event handlers
    on<LoadTheme>(_onLoadTheme);
    on<ToggleTheme>(_onToggleTheme);
  }

  Future<void> _onLoadTheme(
    LoadTheme event,
    Emitter<AppThemeState> emit,
  ) async {
    // Get the shared preferences instance
    final prefs = await SharedPreferences.getInstance();

    // Get the saved theme string. It might be null.
    final String? themeString = prefs.getString(_themeKey);

    if (themeString == 'dark') {
      emit(const AppThemeState(themeMode: ThemeMode.dark));
    } else {
      emit(const AppThemeState(themeMode: ThemeMode.light));
    }
  }

  Future<void> _onToggleTheme(
    ToggleTheme event,
    Emitter<AppThemeState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // Check the current state and determine the new one
    final newThemeMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;

    // Save the new theme preference
    if (newThemeMode == ThemeMode.dark) {
      await prefs.setString(_themeKey, 'dark');
    } else {
      await prefs.setString(_themeKey, 'light');
    }

    // Emit the new state to update the UI
    emit(AppThemeState(themeMode: newThemeMode));
  }
}
