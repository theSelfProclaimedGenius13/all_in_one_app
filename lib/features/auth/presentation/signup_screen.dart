// lib/features/auth/presentation/signup/signup_screen.dart

// Import BLoC files
import 'package:all_in_one_app/features/auth/bloc/auth_bloc.dart';
import 'package:all_in_one_app/features/auth/bloc/auth_event.dart';
import 'package:all_in_one_app/features/auth/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
// DO NOT import AuthApi or AuthRepository

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    // 1. REMOVE THE BlocProvider WRAPPER

    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: BlocConsumer<AuthBloc, Auth_State>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
          if (state is AuthInitial) {
            // After successful signup, Supabase may send a confirmation email
            // or you might be auto-logged in.
            // For now, let's go back to login after signup.
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Signup successful! Please log in.'),
                backgroundColor: Colors.green,
              ),
            );
            context.goNamed('login');
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return Center(child: CircularProgressIndicator());
          }

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
                      SignupRequested(
                        email: emailController.text,
                        password: passwordController.text,
                      ),
                    );
                  },
                  child: Text('Sign Up'),
                ),

                // 2. ADD NAVIGATION BACK TO LOGIN
                TextButton(
                  onPressed: () {
                    context.goNamed('login'); // or context.go('/login')
                  },
                  child: Text("Already have an account? Login"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
