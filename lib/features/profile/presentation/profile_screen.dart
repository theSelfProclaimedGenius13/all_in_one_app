import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import your Auth BLoC and State
import 'package:all_in_one_app/features/auth/bloc/auth_bloc.dart';
import 'package:all_in_one_app/features/auth/bloc/auth_state.dart';

import '../../auth/bloc/auth_event.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // This is how you read the current state from the BLoC
    final authState = context.watch<AuthBloc>().state;

    String userEmail = 'Not logged in';
    String userId = 'N/A';
    if (authState is AuthAuthenticated) {
      userId = authState.user.id;
      userEmail = authState.user.email;
    } else {
      userEmail = 'No Email Provided'; // Handles phone auth
    }

    return Scaffold(
      // Note: The AppBar and Drawer are already provided by your
      // 'ScaffoldWithMenu', so we don't need them here.
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // --- User Information Section ---
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('Email'),
                      subtitle: Text(
                        userEmail,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.vpn_key),
                      title: const Text('User ID'),
                      subtitle: Text(
                        userId,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(), // Pushes the logout button to the bottom
            // --- Logout Button ---
            // Even though it's in the drawer, it's good practice
            // to have a clear logout on the profile page itself.
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  // Find the AuthBloc and add the LogoutRequested event
                  context.read<AuthBloc>().add(LogoutRequested());
                },
              ),
            ),
            const SizedBox(height: 20), // Bottom spacing
          ],
        ),
      ),
    );
  }
}
