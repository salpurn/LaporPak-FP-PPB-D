import 'package:flutter/material.dart';
import 'package:laporpak_fp/core/models/app_user.dart';
import 'package:laporpak_fp/core/widgets/role_badge.dart';
import 'package:laporpak_fp/screens/complete_profile_page.dart';
import 'package:laporpak_fp/services/auth_service.dart';

class AppEndDrawer extends StatelessWidget {
  final AppUser user;

  const AppEndDrawer({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final initials = _initials(user.name);
    final color = Theme.of(context).colorScheme.primary;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              color: color,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: color,
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Opacity(
                    opacity: 0.8,
                    child: Text(
                      user.email,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                  if (user.department.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Opacity(
                      opacity: 0.85,
                      child: Row(
                        children: [
                          const Icon(Icons.business_outlined,
                              size: 13, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            user.department,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 2),
                  Opacity(
                    opacity: 0.75,
                    child: Row(
                      children: [
                        const Icon(Icons.badge_outlined,
                            size: 13, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'ID: ${user.workerId.isNotEmpty ? user.workerId : user.uid.substring(0, 8).toUpperCase()}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  RoleBadge(role: user.role),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CompleteProfilePage(user: user),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {},
            ),
            const Divider(),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      title: const Text('Sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext, false);
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext, true);
                          },
                          child: const Text('Sign out'),
                        ),
                      ],
                    );
                  },
                );

                if (confirmed != true) {
                  return;
                }

                await AuthService().signOut();

                if (!context.mounted) {
                  return;
                }

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return '?';
    }
    final first = parts.first.substring(0, 1).toUpperCase();
    if (parts.length == 1) {
      return first;
    }
    final second = parts[1].substring(0, 1).toUpperCase();
    return '$first$second';
  }
}
