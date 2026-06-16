import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:laporpak_fp/core/constants/enums.dart';
import 'package:laporpak_fp/core/models/app_user.dart';
import 'package:laporpak_fp/core/services/notification_service.dart';
import 'package:laporpak_fp/core/widgets/app_bottom_nav.dart';
import 'package:laporpak_fp/core/widgets/app_end_drawer.dart';
import 'package:laporpak_fp/screens/maintenance/maintenance_history_page.dart';
import 'package:laporpak_fp/screens/notifications_page.dart';
import 'package:laporpak_fp/screens/maintenance/maintenance_home_page.dart';
import 'package:laporpak_fp/screens/supervisor/supervisor_history_page.dart';
import 'package:laporpak_fp/screens/supervisor/supervisor_home_page.dart';
import 'package:laporpak_fp/screens/worker/worker_history_page.dart';
import 'package:laporpak_fp/screens/worker/worker_home_page.dart';

class AppShell extends StatefulWidget {
  final AppUser user;

  const AppShell({super.key, required this.user});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    NotificationService.requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        automaticallyImplyLeading: false,
        title: Text(
          _currentTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        actions: [
          Builder(
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                  child: CircleAvatar(
                    radius: 18,
                    child: Text(_initials(widget.user.name)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      endDrawer: AppEndDrawer(user: widget.user),
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, primary, secondary) {
          return FadeThroughTransition(
            animation: primary,
            secondaryAnimation: secondary,
            child: child,
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _currentBody(),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  String get _currentTitle {
    if (_currentIndex == 1) {
      return 'Notifications';
    }
    if (_currentIndex == 2) {
      return 'History';
    }

    switch (widget.user.role) {
      case UserRole.floorWorker:
        return 'My Reports';
      case UserRole.supervisor:
        return 'Department Dashboard';
      case UserRole.maintenance:
        return 'Task Board';
    }
  }

  Widget _currentBody() {
    if (_currentIndex == 1) {
      return NotificationsPage(user: widget.user);
    }

    if (_currentIndex == 2) {
      switch (widget.user.role) {
        case UserRole.floorWorker:
          return WorkerHistoryPage(user: widget.user);
        case UserRole.supervisor:
          return SupervisorHistoryPage(user: widget.user);
        case UserRole.maintenance:
          return MaintenanceHistoryPage(user: widget.user);
      }
    }

    switch (widget.user.role) {
      case UserRole.floorWorker:
        return WorkerHomePage(user: widget.user);
      case UserRole.supervisor:
        return SupervisorHomePage(user: widget.user);
      case UserRole.maintenance:
        return MaintenanceHomePage(user: widget.user);
    }
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
