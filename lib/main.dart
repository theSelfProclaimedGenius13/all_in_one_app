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
import 'package:all_in_one_app/features/notes/bloc/notes_bloc.dart';
import 'package:all_in_one_app/features/notes/domain/repositories/notes_repositories.dart';
import 'features/notes/bloc/notes_event.dart';
import 'features/notes/data/repositories/notes_repository_impl.dart';
import 'features/pomodoro/bloc/pomodoro_bloc.dart';
import 'features/pomodoro/notification_services.dart';
import 'features/settings/bloc/theme_state.dart';
import 'features/to_do/data/repositories/to_do_repo_impl.dart';
import 'features/to_do/domain/repositories/to_do_repository.dart';
import 'features/weather/data/repositories/weather_repository_impl.dart';
import 'features/weather/domain/repositories/weather_repository.dart';
import 'package:all_in_one_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:all_in_one_app/features/profile/domain/repositories/profile_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final supabaseUrl = dotenv.env['SUPABASE_URL']?.trim();
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']?.trim();

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception(
      'Failed to load .env file. Make sure SUPABASE_URL and SUPABASE_ANON_KEY are set.',
    );
  }
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  final notificationService = NotificationService();
  await notificationService.init();

  runApp(MyApp(notificationService: notificationService));
}

class MyApp extends StatelessWidget {
  final NotificationService notificationService;

  const MyApp({super.key, required this.notificationService});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
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
        RepositoryProvider<ProfileRepository>(
          create: (context) => ProfileRepositoryImpl(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(authRepository: context.read<AuthRepository>()),
          ),
          BlocProvider<ThemeBloc>(
            create: (context) => ThemeBloc()..add(LoadTheme()),
          ),
          BlocProvider<PomodoroBloc>(
            create: (context) =>
                PomodoroBloc(notificationService: notificationService),
          ),
          BlocProvider<NotesBloc>(
            create: (context) =>
                NotesBloc(notesRepository: context.read<NotesRepository>())
                  ..add(LoadNotes()),
          ),
        ],
        child: Builder(
          // Build the router *after* AuthBloc exists, and use the same instance
          builder: (context) {
            final authBloc = context.read<AuthBloc>();
            final GoRouter router = AppRouter(authBloc).router;

            return BlocBuilder<ThemeBloc, AppThemeState>(
              builder: (context, state) {
                return MaterialApp.router(
                  title: 'All In One App',
                  routerConfig: router,
                  debugShowCheckedModeBanner: false,
                  themeMode: state.themeMode,
                  theme: ThemeData.light(),
                  darkTheme: ThemeData.dark(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
