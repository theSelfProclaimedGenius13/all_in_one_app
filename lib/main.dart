import 'package:all_in_one_app/app/router/app_router.dart';
import 'package:all_in_one_app/features/auth/bloc/auth_bloc.dart';
import 'package:all_in_one_app/features/auth/data/auth_api.dart';
import 'package:all_in_one_app/features/auth/data/auth_repository.dart';
import 'package:all_in_one_app/features/settings/bloc/theme_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:all_in_one_app/features/settings/bloc/theme_bloc.dart';

import 'features/notes/data/repositories/notes_repository_impl.dart';
import 'features/notes/domain/repositories/notes_repositories.dart';
import 'features/pomodoro/bloc/pomodoro_bloc.dart';
import 'features/pomodoro/notification_services.dart';
import 'features/settings/bloc/theme_state.dart';
import 'features/to_do/data/repositories/to_do_repo_impl.dart';
import 'features/to_do/domain/repositories/to_do_repository.dart';
import 'features/weather/data/repositories/weather_repository_impl.dart';
import 'features/weather/domain/repositories/weather_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
  // --- 1. INITIALIZE SERVICES ---
  // (Your Supabase URL/key goes here)
  if (supabaseUrl == null || supabaseAnonKey == null) {
    // This will crash the app on purpose if you forget your keys
    throw Exception(
      'Failed to load .env file. Make sure SUPABASE_URL and SUPABASE_ANON_KEY are set.',
    );
  }
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  final notificationService = NotificationService();
  await notificationService.init();

  // --- 2. RUN THE APP ---
  // We'll pass the notification service, but that's it!
  runApp(MyApp(notificationService: notificationService));
}

class MyApp extends StatelessWidget {
  final NotificationService notificationService;

  // --- 3. CREATE THE ROUTER ---
  // We create the router here so it can access the AuthBloc
  late final GoRouter _router;

  MyApp({super.key, required this.notificationService}) {
    // We create a temp AuthBloc *just* for the router's redirect logic
    // This is a common pattern with GoRouter
    final authBloc = AuthBloc(authRepository: AuthRepository(AuthApi()));
    _router = AppRouter(authBloc).router;
  }

  @override
  Widget build(BuildContext context) {
    // --- 4. THE PROVIDER ROOT ---
    return MultiRepositoryProvider(
      providers: [
        // --- Provide all of our repositories here ---
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(AuthApi()),
        ),
        RepositoryProvider<TodoRepository>(
          create: (context) => TodoRepositoryImpl(),
        ),
        RepositoryProvider<NotesRepository>(
          create: (context) => NotesRepositoryImpl(),
        ),
        RepositoryProvider<WeatherRepository>(
          create: (context) => WeatherRepositoryImpl(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // --- Create all global BLoCs here ---
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              // Ask for the repository from the context
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider<ThemeBloc>(
            create: (context) => ThemeBloc()..add(LoadTheme()),
          ),
          BlocProvider<PomodoroBloc>(
            create: (context) =>
                PomodoroBloc(notificationService: notificationService),
          ),
        ],
        child: BlocBuilder<ThemeBloc, AppThemeState>(
          builder: (context, state) {
            return MaterialApp.router(
              title: 'All In One App',
              routerConfig: _router,
              debugShowCheckedModeBanner: false,
              themeMode: state.themeMode,
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
            );
          },
        ),
      ),
    );
  }
}
