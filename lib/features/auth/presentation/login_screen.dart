// lib/features/auth/presentation/login/login_screen.dart

// Import your BLoC files
import 'package:all_in_one_app/features/auth/bloc/auth_bloc.dart';
import 'package:all_in_one_app/features/auth/bloc/auth_event.dart';
import 'package:all_in_one_app/features/auth/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase for OAuthProvider

// DO NOT import AuthApi or AuthRepository here

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    // 1. REMOVE THE BlocProvider WRAPPER
    // The BLoC is now provided by main.dart

    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: BlocConsumer<AuthBloc, Auth_State>(
        // Use BlocConsumer for navigation
        listener: (context, state) {
          // GoRouter's redirect will handle success,
          // but you can show snackbars here if you want.
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return Center(child: CircularProgressIndicator());
          }

          // Don't show AuthError here, the listener handles it.
          // The form should always be visible.

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: "Password"),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                      LoginRequested(
                        email: emailController.text, // <-- Add 'email:'
                        password:
                            passwordController.text, // <-- Add 'password:'
                      ),
                    );
                  },
                  child: Text('Login'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                      SocialLoginRequested(OAuthProvider.google),
                    );
                  },
                  child: Text('Sign in with Google'),
                ),

                // 2. ADD NAVIGATION HERE
                TextButton(
                  onPressed: () {
                    // Navigate to the signup route
                    context.goNamed('signup'); // or context.go('/signup')
                  },
                  child: Text("Don't have an account? Sign Up"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
