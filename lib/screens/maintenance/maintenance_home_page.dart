import 'dart:async';

import 'package:flutter/material.dart';
import 'package:laporpak_fp/core/constants/enums.dart';
import 'package:laporpak_fp/core/models/app_notification.dart';
import 'package:laporpak_fp/core/models/app_user.dart';
import 'package:laporpak_fp/core/models/ticket.dart';
import 'package:laporpak_fp/core/services/firestore/firestore_notification_repository.dart';
import 'package:laporpak_fp/core/services/notification_repository.dart';
import 'package:laporpak_fp/core/services/notification_service.dart';
import 'package:laporpak_fp/screens/maintenance/maintenance_services.dart';
import 'package:laporpak_fp/screens/maintenance/ticket_detail_page.dart';
import 'package:laporpak_fp/screens/maintenance/widgets/task_card.dart';

class MaintenanceHomePage extends StatefulWidget {
  final AppUser user;

  const MaintenanceHomePage({super.key, required this.user});

  @override
  State<MaintenanceHomePage> createState() => _MaintenanceHomePageState();
}

class _MaintenanceHomePageState extends State<MaintenanceHomePage> {
  final _repo = MaintenanceServices.instance.repo;
  final NotificationRepository _notifRepo = FirestoreNotificationRepository();

  StreamSubscription<List<Ticket>>? _notifSub;
  final Map<String, TicketStatus> _knownStatuses = {};
  bool _notifInitialized = false;

  static const _activeStatuses = {
    TicketStatus.assigned,
    TicketStatus.rejected,
  };

  @override
  void initState() {
    super.initState();
    _startNotificationListener();
  }

  void _startNotificationListener() {
    _notifSub = _repo.watchByAssignee(widget.user.uid).listen((tickets) {
      if (!_notifInitialized) {
        _notifInitialized = true;
        for (final t in tickets) {
          _knownStatuses[t.id] = t.status;
        }
        return;
      }
      for (final t in tickets) {
        final prev = _knownStatuses[t.id];
        if (t.status == TicketStatus.assigned && prev != TicketStatus.assigned) {
          const title = 'New Task Assigned';
          final body = 'You have been assigned: ${t.title}';
          NotificationService.show(id: t.id.hashCode, title: title, body: body);
          _notifRepo.add(AppNotification(
            id: '',
            recipientId: widget.user.uid,
            title: title,
            body: body,
            ticketId: t.id,
            isRead: false,
            createdAt: DateTime.now(),
          ));
        }
        _knownStatuses[t.id] = t.status;
      }
    });
  }

  @override
  void dispose() {
    _notifSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Ticket>>(
      stream: _repo.watchByAssignee(widget.user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load tasks',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    snapshot.error.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final active = (snapshot.data ?? [])
            .where((t) => _activeStatuses.contains(t.status))
            .toList()
          ..sort(_sortTickets);

        if (active.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                SizedBox(height: 16),
                Text(
                  'All clear!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  'No active tasks assigned to you.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: active.length,
          itemBuilder: (context, index) {
            final ticket = active[index];
            return TaskCard(
              ticket: ticket,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TicketDetailPage(ticket: ticket, user: widget.user),
                ),
              ),
            );
          },
        );
      },
    );
  }

  int _sortTickets(Ticket a, Ticket b) {
    final now = DateTime.now();
    final aOverdue = a.deadline != null && a.deadline!.isBefore(now);
    final bOverdue = b.deadline != null && b.deadline!.isBefore(now);

    if (aOverdue && !bOverdue) return -1;
    if (!aOverdue && bOverdue) return 1;

    final urgencyOrder = {
      UrgencyLevel.critical: 0,
      UrgencyLevel.high: 1,
      UrgencyLevel.medium: 2,
      UrgencyLevel.low: 3,
    };
    return (urgencyOrder[a.urgency] ?? 4).compareTo(urgencyOrder[b.urgency] ?? 4);
  }
}
