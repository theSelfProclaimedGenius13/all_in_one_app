import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/theme_bloc.dart';
import '../bloc/theme_event.dart';
import '../bloc/theme_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Note: No AppBar needed, 'ScaffoldWithMenu' provides it
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // --- 2. USE BlocBuilder TO GET THE CURRENT THEME ---
            BlocBuilder<ThemeBloc, AppThemeState>(
              builder: (context, state) {
                // This builder will rebuild *only* this one ListTile
                // when the theme state changes.
                return ListTile(
                  title: const Text('Dark Mode'),
                  leading: const Icon(Icons.dark_mode_outlined),

                  // --- 3. THE SWITCH WIDGET ---
                  trailing: Switch(
                    // Set the switch's position based on the BLoC's state
                    value: state.themeMode == ThemeMode.dark,

                    onChanged: (newValue) {
                      // On change, fire the ToggleTheme event
                      context.read<ThemeBloc>().add(ToggleTheme());
                    },
                  ),
                );
              },
            ),
            // You can add more settings ListTiles here later
          ],
        ),
      ),
    );
  }
}
