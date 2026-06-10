import 'package:flutter/material.dart';
import 'package:laporpak_fp/core/models/app_user.dart';
import '../services/auth_service.dart';

class HomePage extends StatelessWidget {
  final AppUser user;

  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${user.role.name} Dashboard'),
        actions: [
          IconButton(
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${user.name}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text('Role: ${user.role.name}'),
            Text('Department: ${user.department}'),
          ],
        ),
      ),
    );
  }
}
