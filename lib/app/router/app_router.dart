// lib/config/router.dart

import 'package:all_in_one_app/features/calculator/presentation/basic_calculator_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import your pages and BLoC
import 'package:all_in_one_app/features/auth/presentation/login_screen.dart';
import 'package:all_in_one_app/features/auth/presentation/signup_screen.dart';
import 'package:all_in_one_app/app/homepage.dart'; // We'll create this
// We'll create this
import 'package:all_in_one_app/features/auth/bloc/auth_bloc.dart';
import 'package:all_in_one_app/features/auth/bloc/auth_state.dart';

import '../scaffold_with_menu.dart';

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
          return ScaffoldWithMenu(child: child, state: state);
        },

        // --- Pages inside the Shell ---
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => HomePage(),
          ),
          GoRoute(
            path: '/basic_calculator',
            name: 'basic_calculator',
            builder: (context, state) => BasicCalculator(),
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
