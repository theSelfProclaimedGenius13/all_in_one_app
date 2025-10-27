// lib/presentation/scaffold_with_menu.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:all_in_one_app/features/auth/bloc/auth_bloc.dart';
import 'package:all_in_one_app/features/auth/bloc/auth_event.dart';

class ScaffoldWithMenu extends StatelessWidget {
  final Widget child; // This is the page to display (e.g., HomePage)
  final GoRouterState state;

  const ScaffoldWithMenu({super.key, required this.child, required this.state});

  @override
  Widget build(BuildContext context) {
    final currentRoute = state.name ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text("Home-Page"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      // This is your side menu bar
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // 2. This is your new header
            Container(
              // This calculates the exact height of the AppBar + Status Bar
              height: kToolbarHeight + MediaQuery.of(context).padding.top,
              color: Colors.blue, // Or your app's primary color
              child: Padding(
                // 3. This pushes the "Menu" text down below the status bar
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  left: 16.0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 3,
              child: Divider(color: Colors.blue, thickness: 2),
            ), // --- This is your navigation logic ---
            ListTile(
              tileColor: Colors.teal,
              // <-- Add this
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                context.goNamed('home');
                Navigator.of(context).pop();
              },
            ),
            SizedBox(
              height: 3,
              child: Divider(color: Colors.blue, thickness: 2),
            ),
            ListTile(
              tileColor: Colors.teal,
              // <-- Add this
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // context.goNamed('settings'); // (remember to add this to your router)
                Navigator.of(context).pop();
              },
            ),
            SizedBox(
              height: 3,
              child: Divider(color: Colors.blue, thickness: 2),
            ),
            ListTile(
              tileColor: Colors.teal,
              // <-- Add this
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                context.read<AuthBloc>().add(LogoutRequested());
                Navigator.of(context).pop(); // Close the drawer
                // GoRouter's redirect logic will automatically send you to /login
              },
            ),
            SizedBox(
              height: 3,
              child: Divider(color: Colors.blue, thickness: 2),
            ),
            ListTile(
              tileColor: Colors.teal,
              // <-- Add this
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              leading: Icon(Icons.sticky_note_2_rounded),
              title: Text('ToDo'),
              onTap: () {
                context.read<AuthBloc>().add(LogoutRequested());
                Navigator.of(context).pop(); // Close the drawer
                // GoRouter's redirect logic will automatically send you to /login
              },
            ),
            SizedBox(
              height: 3,
              child: Divider(color: Colors.blue, thickness: 2),
            ),
          ],
        ),
      ),
      // The main content (HomePage, SettingsPage, etc.)
      body: child,
    );
  }
}
