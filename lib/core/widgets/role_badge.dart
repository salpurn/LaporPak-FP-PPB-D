import 'package:flutter/material.dart';
import 'package:laporpak_fp/core/constants/enums.dart';

class RoleBadge extends StatelessWidget {
  final UserRole role;

  const RoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final color = _roleColor(role);
    final label = _roleLabel(role);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _roleColor(UserRole role) {
    switch (role) {
      case UserRole.floorWorker:
        return const Color(0xFF1976D2);
      case UserRole.supervisor:
        return const Color(0xFF7C4DFF);
      case UserRole.maintenance:
        return const Color(0xFFF2A227);
    }
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.floorWorker:
        return 'Floor Worker';
      case UserRole.supervisor:
        return 'Supervisor';
      case UserRole.maintenance:
        return 'Maintenance';
    }
  }
}
