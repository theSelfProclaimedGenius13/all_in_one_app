import 'package:all_in_one_app/app/router/app_router.dart';
import 'package:all_in_one_app/features/auth/bloc/auth_bloc.dart';
import 'package:all_in_one_app/features/auth/data/auth_api.dart';
import 'package:all_in_one_app/features/auth/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://hqegfonbltywlpxuwryj.supabase.co';
const supabaseKey = String.fromEnvironment('SUPABASE_KEY');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey, // <-- put your anon/public key here
  );
  // --- Create your instances HERE ---
  final authApi = AuthApi();
  final authRepository = AuthRepository(authApi);
  final authBloc = AuthBloc(authRepository);

  // Create the router and pass it the AuthBloc
  final appRouter = AppRouter(authBloc);
  runApp(
    MyApp(
      authBloc: authBloc,
      router: appRouter.router, // Pass the configured router
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthBloc authBloc;
  final GoRouter router;

  const MyApp({super.key, required this.authBloc, required this.router});

  @override
  Widget build(BuildContext context) {
    // --- Provide your BLoC HERE ---
    // This one BlocProvider is shared with the entire app
    return BlocProvider.value(
      value: authBloc,
      child: MaterialApp.router(
        title: 'All In One App',

        // --- Use the routerConfig ---
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
// class MyApp extends StatelessWidget {
//   final AuthBloc authBloc;
//   final GoRouter router;
//
//   const MyApp({super.key, required this.authBloc, required this.router});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'All In One App',
//       home: HomePage(), // or your first route
//     );
//   }
// }

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           centerTitle: true,
//           title: const Text('HomePage'),
//           backgroundColor: Colors.blue,
//           leading: Builder(
//             builder: (context) => IconButton(
//               icon: Icon(Icons.menu),
//               onPressed: () {
//                 Scaffold.of(context).openDrawer();
//               },
//             ),
//           ),
//           actions: <Widget>[
//             IconButton(onPressed: null, icon: Icon(Icons.settings)),
//           ],
//         ),
//
//         drawer: Drawer(
//           child: ListView(
//             padding: EdgeInsets.zero,
//             children: [
//               Container(
//                 decoration: BoxDecoration(color: Colors.blue),
//                 padding: EdgeInsets.zero,
//                 margin: EdgeInsets.zero,
//                 child: SizedBox(
//                   height: kToolbarHeight,
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       'Menu',
//                       style: TextStyle(color: Colors.white, fontSize: 24),
//                     ),
//                   ),
//                 ),
//               ),
//               ListTile(
//                 leading: Icon(Icons.home),
//                 title: Text('Home'),
//                 onTap: null,
//               ),
//               ListTile(
//                 leading: Icon(Icons.settings),
//                 title: Text('Settings'),
//                 onTap: null,
//               ),
//               ListTile(
//                 leading: Icon(Icons.settings),
//                 title: Text('Calculator'),
//                 onTap: null,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
