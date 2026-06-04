import 'package:flutter/material.dart';
import 'package:laporpak_fp/core/models/app_user.dart';

class MaintenanceHomePage extends StatelessWidget {
  final AppUser user;

  const MaintenanceHomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Module C — Maintenance (work in progress)'),
    );
  }
}
