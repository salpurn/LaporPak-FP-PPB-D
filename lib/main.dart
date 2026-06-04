import 'package:flutter/material.dart';
<<<<<<< Updated upstream
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/auth_page.dart';
import 'screens/home_page.dart';
=======
import 'package:laporpak_fp/core/models/app_user.dart';
import 'package:laporpak_fp/firebase_options.dart';
import 'package:laporpak_fp/screens/auth_page.dart';
import 'package:laporpak_fp/screens/home_page.dart';
import 'package:laporpak_fp/screens/maintenance/maintenance_home_page.dart';
import 'package:laporpak_fp/screens/supervisor/supervisor_home_page.dart';
import 'package:laporpak_fp/screens/worker/worker_home_page.dart';
import 'package:laporpak_fp/services/auth_service.dart';
>>>>>>> Stashed changes

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LaporPak',
<<<<<<< Updated upstream
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            return const HomePage();
          }
=======
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B4D8C)),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const AuthPage(),
        '/home': (context) => const _HomeRoute(),
        '/worker-dashboard': (context) => const _WorkerDashboardRoute(),
        '/supervisor-dashboard': (context) => const _SupervisorDashboardRoute(),
        '/maintenance-dashboard': (context) =>
            const _MaintenanceDashboardRoute(),
      },
    );
  }
}

class _HomeRoute extends StatelessWidget {
  const _HomeRoute();

  @override
  Widget build(BuildContext context) {
    return _UserGate(builder: (user) => RoleHomePage(user: user));
  }
}

class _WorkerDashboardRoute extends StatelessWidget {
  const _WorkerDashboardRoute();

  @override
  Widget build(BuildContext context) {
    return _UserGate(builder: (user) => WorkerHomePage(user: user));
  }
}

class _SupervisorDashboardRoute extends StatelessWidget {
  const _SupervisorDashboardRoute();

  @override
  Widget build(BuildContext context) {
    return _UserGate(builder: (user) => SupervisorHomePage(user: user));
  }
}

class _MaintenanceDashboardRoute extends StatelessWidget {
  const _MaintenanceDashboardRoute();

  @override
  Widget build(BuildContext context) {
    return _UserGate(builder: (user) => MaintenanceHomePage(user: user));
  }
}

class _UserGate extends StatelessWidget {
  final Widget Function(AppUser user) builder;

  const _UserGate({required this.builder});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
>>>>>>> Stashed changes
          return const AuthPage();
        },
      ),
    );
  }
}
