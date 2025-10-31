import 'package:all_in_one_app/app/router/app_router.dart';
import 'package:all_in_one_app/features/auth/bloc/auth_bloc.dart';
import 'package:all_in_one_app/features/auth/data/auth_api.dart';
import 'package:all_in_one_app/features/auth/data/auth_repository.dart';
import 'package:all_in_one_app/features/settings/bloc/theme_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:all_in_one_app/features/settings/bloc/theme_bloc.dart';

import 'package:all_in_one_app/app/theme/app_theme.dart';

import 'features/pomodoro/bloc/pomodoro_bloc.dart';
import 'features/pomodoro/notification_services.dart';
import 'features/settings/bloc/theme_state.dart';

const supabaseUrl = 'https://hqegfonbltywlpxuwryj.supabase.co';
const supabaseKey = String.fromEnvironment('SUPABASE_KEY');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // --- 2. INITIALIZE THE NOTIFICATION SERVICE ---
  final notificationService = NotificationService();
  await notificationService.init(); // Wait for it to be ready
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  // --- Create your instances HERE ---
  final authApi = AuthApi();
  final authRepository = AuthRepository(authApi);
  final authBloc = AuthBloc(authRepository);
  final themeBloc = ThemeBloc()..add(LoadTheme());
  final pomodoroBloc = PomodoroBloc(notificationService: notificationService);

  // Create the router and pass it the AuthBloc
  final appRouter = AppRouter(authBloc);
  runApp(
    MyApp(
      authBloc: authBloc,
      themeBloc: themeBloc,
      pomodoroBloc: pomodoroBloc,
      router: appRouter.router, // Pass the configured router
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthBloc authBloc;
  final ThemeBloc themeBloc;
  final PomodoroBloc pomodoroBloc;
  final GoRouter router;

  const MyApp({
    super.key,
    required this.authBloc,
    required this.themeBloc,
    required this.pomodoroBloc,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    // --- Provide your BLoC HERE ---

    return MultiBlocProvider(
      providers: [
        // The existing AuthBloc provider
        BlocProvider.value(value: authBloc),
        // The new ThemeBloc provider
        BlocProvider.value(value: themeBloc),
        BlocProvider.value(value: pomodoroBloc),
      ],
      child: BlocBuilder<ThemeBloc, AppThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'All In One App',

            // --- Use the routerConfig ---
            routerConfig: router,
            debugShowCheckedModeBanner: false,
            themeMode: state.themeMode,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
          );
        },
      ),
    );
  }
}
