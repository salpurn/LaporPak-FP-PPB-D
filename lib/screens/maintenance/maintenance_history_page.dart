import 'package:flutter/material.dart';
import 'package:laporpak_fp/core/models/app_user.dart';

class MaintenanceHistoryPage extends StatelessWidget {
  final AppUser user;

  const MaintenanceHistoryPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Maintenance History — Module C (your work)'),
    );
  }
}
