// lib/config/router.dart

import 'package:all_in_one_app/app/homepage.dart';

import 'package:all_in_one_app/features/auth/bloc/auth_bloc.dart';
import 'package:all_in_one_app/features/auth/bloc/auth_state.dart';

import 'package:all_in_one_app/features/auth/presentation/login_screen.dart';
import 'package:all_in_one_app/features/auth/presentation/signup_screen.dart';
import 'package:all_in_one_app/features/calculator/presentation/basic_calculator_screen.dart';
import 'package:all_in_one_app/features/pomodoro/presentation/pomodoro_timer_screen.dart';
import 'package:all_in_one_app/features/to_do/presentation/to_do_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:all_in_one_app/features/weather/presentation/weather_screen.dart';
import '../../features/calculator/presentation/advance_calculator_screen.dart';

import '../../features/donate/presentation/donate_screen.dart';
import '../../features/notes/presentation/add_edit_notes_screen.dart';
import '../../features/notes/presentation/notes_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/to_do/bloc/todo_bloc.dart';
import '../../features/to_do/bloc/todo_event.dart';
import '../../features/to_do/domain/repositories/to_do_repository.dart';
import '../scaffold_with_menu.dart';
import 'package:all_in_one_app/features/profile/presentation/profile_screen.dart';

// Key for the ShellRoute's navigator
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: '/login', // Start at the login page
    // This tells GoRouter to re-check the routes when the auth state changes
    refreshListenable: GoRouterRefreshStream(authBloc.stream),

    routes: [
      // --- Top-Level Routes (No Menu Bar) ---
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => SignupScreen(),
      ),

      // --- Shell Route (This has your Menu Bar) ---
      ShellRoute(
        navigatorKey: _shellNavigatorKey,

        // This is your main scaffold with the menu
        builder: (context, state, child) {
          return ScaffoldWithMenu(state: state, child: child);
        },

        // --- Pages inside the Shell ---
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => HomePage(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => ProfilePage(),
          ),
          GoRoute(
            path: '/basic_calculator',
            name: 'basic_calculator',
            builder: (context, state) => BasicCalculator(),
          ),
          GoRoute(
            path: '/scientific_calculator',
            name: 'scientific_calculator',
            builder: (context, state) => const ScientificCalculator(),
          ),
          GoRoute(
            path: '/weather',
            name: 'weather',
            builder: (context, state) => const WeatherScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => SettingsScreen(),
          ),
          GoRoute(
            path: '/pomodoro',
            name: 'pomodoro',
            builder: (context, state) => const PomodoroScreen(),
          ),
          GoRoute(
            path: '/todo',
            name: 'todo',
            builder: (context, state) {
              // This provides the BLoC to the ToDoScreen
              return BlocProvider(
                create: (context) => TodoBloc(
                  // Ask the provider tree for the repository
                  todoRepository: context.read<TodoRepository>(),
                )..add(LoadTodos()), // <-- This loads data immediately
                child: const ToDoScreen(),
              );
            },
          ),
          GoRoute(
            path: '/notes',
            name: 'notes',
            // The builder just returns the screen now.
            // The BLoC is already provided by main.dart.
            builder: (context, state) => const NotesView(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'add_note',
                builder: (context, state) =>
                    const AddEditNoteScreen(noteId: null),
              ),
              GoRoute(
                path: 'edit/:id',
                name: 'edit_note',
                builder: (context, state) {
                  final id = state.pathParameters['id'];
                  return AddEditNoteScreen(noteId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/donate',
            name: 'donate',
            builder: (context, state) => const DonateScreen(),
          ),

          // Add other pages with the menu bar here
          // e.g., GoRoute(path: '/settings', ...),
        ],
      ),
    ],

    // --- Auth Redirect Logic ---
    redirect: (BuildContext context, GoRouterState state) {
      final authState = authBloc.state;

      // Get the locations for login and signup pages
      final onLoginPage = state.matchedLocation == '/login';
      final onSignupPage = state.matchedLocation == '/signup';
      final onAuthPages = onLoginPage || onSignupPage;

      // IF user is NOT authenticated:
      if (authState is! AuthAuthenticated) {
        // If they are not on login or signup, send them to /login
        return onAuthPages ? null : '/login';
      }

      // IF user IS authenticated:
      if (onAuthPages) {
        // If they are on the login or signup page, send them home
        return '/home';
      }

      // No redirect needed
      return null;
    },
  );
}

// Helper class to bridge BLoC stream with GoRouter's Listenable
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}
