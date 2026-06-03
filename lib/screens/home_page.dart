import 'package:flutter/material.dart';
import 'package:laporpak_fp/core/models/app_user.dart';
import 'package:laporpak_fp/core/widgets/app_shell.dart';

class RoleHomePage extends StatelessWidget {
  final AppUser user;

  const RoleHomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AppShell(user: user);
  }
}
