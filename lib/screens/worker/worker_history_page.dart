import 'package:flutter/material.dart';
import 'package:laporpak_fp/core/constants/enums.dart';
import 'package:laporpak_fp/core/models/app_user.dart';
import 'package:laporpak_fp/core/models/ticket.dart';
import 'package:laporpak_fp/screens/maintenance/widgets/task_card.dart';
import 'package:laporpak_fp/screens/worker/worker_services.dart';
import 'package:laporpak_fp/screens/worker/worker_ticket_detail_page.dart';

class WorkerHistoryPage extends StatelessWidget {
  final AppUser user;

  const WorkerHistoryPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final repo = WorkerServices.instance.repo;

    return StreamBuilder<List<Ticket>>(
      stream: repo.watchByWorker(user.workerId),
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
                    'Failed to load history',
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

        final done = (snapshot.data ?? [])
            .where((t) =>
                t.status == TicketStatus.closed ||
                t.status == TicketStatus.rejected)
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

        if (done.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No completed reports yet.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: done.length,
          itemBuilder: (context, index) {
            final ticket = done[index];
            return TaskCard(
              ticket: ticket,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      WorkerTicketDetailPage(ticket: ticket, user: user),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
