import 'package:flutter/material.dart';
import 'package:laporpak_fp/core/constants/enums.dart';
import 'package:laporpak_fp/core/models/app_user.dart';
import 'package:laporpak_fp/core/models/ticket.dart';
import 'package:laporpak_fp/screens/maintenance/maintenance_services.dart';
import 'package:laporpak_fp/screens/maintenance/ticket_detail_page.dart';
import 'package:laporpak_fp/screens/maintenance/widgets/task_card.dart';

class MaintenanceHomePage extends StatelessWidget {
  final AppUser user;

  const MaintenanceHomePage({super.key, required this.user});

  static const _activeStatuses = {
    TicketStatus.assigned,
    TicketStatus.rejected,
    TicketStatus.pendingValidation,
  };

  @override
  Widget build(BuildContext context) {
    final repo = MaintenanceServices.instance.repo;

    return StreamBuilder<List<Ticket>>(
      stream: repo.watchByAssignee(user.uid),
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
                  builder: (_) => TicketDetailPage(ticket: ticket, user: user),
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

    // Overdue first
    if (aOverdue && !bOverdue) return -1;
    if (!aOverdue && bOverdue) return 1;

    // Then by urgency (critical → high → medium → low)
    final urgencyOrder = {
      UrgencyLevel.critical: 0,
      UrgencyLevel.high: 1,
      UrgencyLevel.medium: 2,
      UrgencyLevel.low: 3,
    };
    return (urgencyOrder[a.urgency] ?? 4).compareTo(urgencyOrder[b.urgency] ?? 4);
  }
}
