import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:laporpak_fp/core/models/app_user.dart';
import 'package:laporpak_fp/core/services/notification_service.dart';
import 'package:laporpak_fp/core/widgets/app_shell.dart';
import 'package:laporpak_fp/firebase_options.dart';
import 'package:laporpak_fp/screens/auth_page.dart';
import 'package:laporpak_fp/screens/complete_profile_page.dart';
import 'package:laporpak_fp/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LaporPak',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B4D8C)),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const AuthPage(),
        '/worker-dashboard': (context) => const _UserGate(),
        '/supervisor-dashboard': (context) => const _UserGate(),
        '/maintenance-dashboard': (context) => const _UserGate(),
      },
    );
  }
}

class _UserGate extends StatelessWidget {
  const _UserGate();

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.watchAuthState(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData) {
          return const AuthPage();
        }

        return FutureBuilder<AppUser>(
          future: authService.currentUser(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            if (userSnapshot.hasError || !userSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: Text('User profile not found.')),
              );
            }

            final currentUser = userSnapshot.data!;

            if (currentUser.workerId.isEmpty || currentUser.department.isEmpty) {
              return CompleteProfilePage(user: currentUser);
            }

            return AppShell(user: currentUser);
          },
        );
      },
    );
  }
}
