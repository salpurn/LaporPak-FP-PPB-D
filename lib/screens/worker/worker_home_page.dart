import 'package:flutter/material.dart';
import 'package:laporpak_fp/core/constants/enums.dart';
import 'package:laporpak_fp/core/models/app_user.dart';
import 'package:laporpak_fp/core/models/ticket.dart';
import 'package:laporpak_fp/screens/maintenance/widgets/status_badge.dart';
import 'package:laporpak_fp/screens/worker/worker_services.dart';
import 'package:laporpak_fp/screens/worker/worker_ticket_detail_page.dart';
import 'package:laporpak_fp/screens/worker/worker_ticket_form_page.dart';

class WorkerHomePage extends StatelessWidget {
  final AppUser user;

  const WorkerHomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final repo = WorkerServices.instance.repo;

    return Scaffold(
      body: StreamBuilder<List<Ticket>>(
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
                      'Failed to load reports',
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

          final tickets = (snapshot.data ?? [])
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          if (tickets.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.report_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'No reports yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap + to submit a new hazard report.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return _HazardTicketCard(
                ticket: ticket,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WorkerTicketDetailPage(ticket: ticket, user: user),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WorkerTicketFormPage(user: user),
          ),
        ),
        tooltip: 'Submit hazard report',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _HazardTicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onTap;

  const _HazardTicketCard({required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOverdue = ticket.deadline != null &&
        ticket.deadline!.isBefore(DateTime.now()) &&
        ticket.status != TicketStatus.closed;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isOverdue
            ? const BorderSide(color: Color(0xFFD32F2F), width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      ticket.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(status: ticket.status),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      ticket.location,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                ticket.description,
                style: const TextStyle(fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _CategoryChip(category: ticket.category),
                  const SizedBox(width: 8),
                  _UrgencyChip(urgency: ticket.urgency),
                  const Spacer(),
                  if (ticket.deadline != null)
                    _DeadlineChip(deadline: ticket.deadline!, isOverdue: isOverdue),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final HazardCategory category;
  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _label,
        style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
      ),
    );
  }

  String get _label {
    switch (category) {
      case HazardCategory.electrical: return 'Electrical';
      case HazardCategory.chemical: return 'Chemical';
      case HazardCategory.structural: return 'Structural';
      case HazardCategory.janitorial: return 'Janitorial';
    }
  }
}

class _UrgencyChip extends StatelessWidget {
  final UrgencyLevel urgency;
  const _UrgencyChip({required this.urgency});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _label,
        style: TextStyle(fontSize: 11, color: _color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Color get _color {
    switch (urgency) {
      case UrgencyLevel.low: return const Color(0xFF388E3C);
      case UrgencyLevel.medium: return const Color(0xFFF57C00);
      case UrgencyLevel.high: return const Color(0xFFE64A19);
      case UrgencyLevel.critical: return const Color(0xFFD32F2F);
    }
  }

  String get _label {
    switch (urgency) {
      case UrgencyLevel.low: return 'Low';
      case UrgencyLevel.medium: return 'Medium';
      case UrgencyLevel.high: return 'High';
      case UrgencyLevel.critical: return 'Critical';
    }
  }
}

class _DeadlineChip extends StatelessWidget {
  final DateTime deadline;
  final bool isOverdue;
  const _DeadlineChip({required this.deadline, required this.isOverdue});

  @override
  Widget build(BuildContext context) {
    final color = isOverdue ? const Color(0xFFD32F2F) : Colors.grey.shade600;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isOverdue ? Icons.warning_amber_rounded : Icons.schedule,
          size: 13,
          color: color,
        ),
        const SizedBox(width: 3),
        Text(
          _formatDeadline(),
          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  String _formatDeadline() {
    final now = DateTime.now();
    final diff = deadline.difference(now);
    if (isOverdue) {
      final hours = diff.inHours.abs();
      if (hours < 24) return 'Overdue ${hours}h';
      return 'Overdue ${diff.inDays.abs()}d';
    }
    if (diff.inHours < 24) return 'Due in ${diff.inHours}h';
    return 'Due in ${diff.inDays}d';
  }
}
