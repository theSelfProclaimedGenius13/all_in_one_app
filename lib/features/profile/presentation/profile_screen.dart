import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Import your Auth BLoC and State
import 'package:all_in_one_app/features/auth/bloc/auth_bloc.dart';
import 'package:all_in_one_app/features/auth/bloc/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // This is how you read the current state from the BLoC
    final authState = context.watch<AuthBloc>().state;

    String userEmail = 'Loading...';
    if (authState is AuthAuthenticated) {
      userEmail = authState.user.email;
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Profile Page',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 20),
            Text('Welcome, $userEmail'),
            // You can add more user details here
          ],
        ),
      ),
    );
  }
}
