import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../data/auth_api.dart';
import '../data/auth_repository.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return BlocProvider(
      create: (_) => AuthBloc(AuthRepository(AuthApi())),
      child: Scaffold(
        appBar: AppBar(title: Text("Sign Up")),
        body: BlocBuilder<AuthBloc, Auth_State>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return Center(child: CircularProgressIndicator());
            }
            if (state is AuthError) {
              return Center(
                child: Text(state.error, style: TextStyle(color: Colors.red)),
              );
            }
            return Padding(
              padding: EdgeInsets.all(16.0),
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
                      BlocProvider.of<AuthBloc>(context).add(
                        SignupRequested(
                          emailController.text,
                          passwordController.text,
                        ),
                      );
                    },
                    child: Text('Sign Up'),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to login
                    },
                    child: Text("Already have an account? Login"),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
