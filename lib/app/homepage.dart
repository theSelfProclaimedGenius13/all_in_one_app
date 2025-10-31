import 'package:all_in_one_app/features/auth/bloc/auth_bloc.dart';
import 'package:all_in_one_app/features/auth/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Get the whole state without casting
    final authState = context.watch<AuthBloc>().state;

    // 2. Check the state type
    if (authState is AuthAuthenticated) {
      // 3. We are authenticated! Now it's safe to access the user.
      final user = authState.user;
      return Scaffold(
        body: Center(
          // Use the user's email or a welcome message
          child: Text('Welcome, ${user.email}!'),
        ),
      );
    }

    // 4. If the state is AuthInitial or AuthLoading,
    // just show a loading spinner. The router will redirect
    // away from this page if auth fails.
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
