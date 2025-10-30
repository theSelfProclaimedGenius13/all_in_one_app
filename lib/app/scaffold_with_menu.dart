// lib/presentation/scaffold_with_menu.dart

import 'package:all_in_one_app/features/auth/bloc/auth_bloc.dart';
import 'package:all_in_one_app/features/auth/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithMenu extends StatelessWidget {
  final Widget child; // This is the page to display (e.g., HomePage)
  final GoRouterState state;

  const ScaffoldWithMenu({super.key, required this.child, required this.state});

  @override
  Widget build(BuildContext context) {
    // This variable is now used to highlight the selected item
    final currentRoute = state.name ?? '';

    // --- 1. DEFINE YOUR NAVIGATION ITEMS IN ONE PLACE ---
    // This makes it super easy to add or remove items
    final navItems = [
      {'title': 'Home', 'icon': Icons.home, 'routeName': 'home'},

      // --- HERE IS THE NEW PROFILE ITEM YOU WANTED ---
      {'title': 'Profile', 'icon': Icons.person, 'routeName': 'profile'},
      {'title': 'Notes', 'icon': Icons.note_alt_outlined, 'routeName': 'notes'},
      {
        'title': 'Calculator',
        'icon': Icons.calculate_outlined,
        'routeName': 'basic_calculator',
      },
      {
        'title': 'Pomodoro',
        'icon': Icons.timer_outlined,
        'routeName': 'pomodoro',
      },

      {'title': 'Settings', 'icon': Icons.settings, 'routeName': 'settings'},
      {
        'title': 'ToDo',
        'icon': Icons.sticky_note_2_rounded,
        'routeName': 'todo',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("All In One App"), // You can make this dynamic later
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        // --- 2. USE A COLUMN TO SEPARATE THE LIST AND LOGOUT BUTTON ---
        child: Column(
          children: [
            // Your header (this code was perfect)
            Container(
              height: kToolbarHeight + MediaQuery.of(context).padding.top,
              color: Colors.blue,
              child: Padding(
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

            // --- 3. USE AN EXPANDED LISTVIEW.SEPARATED TO BUILD THE LIST ---
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(
                  8.0,
                ), // Add padding around the list
                itemCount: navItems.length,

                // --- This builds your divider (no more repetition!) ---
                separatorBuilder: (context, index) => SizedBox(height: 4),

                // --- This builds each ListTile from your list ---
                itemBuilder: (context, index) {
                  final item = navItems[index];
                  final isSelected = currentRoute == item['routeName'];

                  return ListTile(
                    tileColor: Colors.teal.withValues(alpha: 0.8),
                    // Your color
                    shape: RoundedSuperellipseBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    leading: Icon(
                      item['icon'] as IconData,
                      color: Colors.white,
                    ),
                    title: Text(
                      item['title'] as String,
                      style: TextStyle(color: Colors.white),
                    ),

                    // --- 4. THIS FIXES THE HIGHLIGHTING ---
                    selected: isSelected,
                    selectedTileColor: Colors.teal,
                    // Makes selected item darker
                    selectedColor: Colors.white,

                    onTap: () {
                      // --- 5. THIS FIXES YOUR NAVIGATION ---
                      // Make sure to add 'profile', 'settings', and 'todo'
                      // to your GoRouter routes in router.dart!
                      context.goNamed(item['routeName'] as String);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),

            // --- 6. PUT THE LOGOUT BUTTON AT THE BOTTOM, SEPARATELY ---
            Divider(color: Colors.blue, thickness: 2),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                tileColor: Colors.teal.withValues(alpha: 0.8),
                shape: RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                leading: Icon(Icons.logout, color: Colors.white),
                title: Text('Logout', style: TextStyle(color: Colors.white)),
                onTap: () {
                  context.read<AuthBloc>().add(LogoutRequested());
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
      body: child,
    );
  }
}
