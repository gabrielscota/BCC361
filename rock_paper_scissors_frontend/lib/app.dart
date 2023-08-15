import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rock_paper_scissors_frontend/room_page.dart';

import 'home_page.dart';
import 'models/models.dart';
import 'username_page.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _routerConfig;

  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();

    _routerConfig = GoRouter(
      initialLocation: '/',
      navigatorKey: _navigatorKey,
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const UsernamePage(),
        ),
        GoRoute(
          name: 'home',
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          name: 'room',
          path: '/room/:id',
          builder: (BuildContext context, GoRouterState state) {
            return RoomPage(
              room: state.extra as RoomModel,
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BCC361 - TP (Pedra, Papel e Tesoura)',
      routerConfig: _routerConfig,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey.shade900,
          primary: Colors.grey.shade900,
          secondary: Colors.grey.shade900,
        ),
      ),
    );
  }
}
