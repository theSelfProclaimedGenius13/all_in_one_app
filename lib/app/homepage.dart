// lib/presentation/home_page.dart

import 'package:all_in_one_app/features/auth/bloc/auth_bloc.dart';
import 'package:all_in_one_app/features/auth/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // You can get the user's info like this:
    final user = (context.watch<AuthBloc>().state as AuthAuthenticated).user;

    return Scaffold(body: Center(child: Text('Welcome ${user.email}!')));
  }
}
