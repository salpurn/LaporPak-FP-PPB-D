import 'package:flutter/material.dart';
import 'package:laporpak_fp/core/constants/enums.dart';
import 'package:laporpak_fp/core/models/ticket.dart';

class SupervisorTicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onTap;

  const SupervisorTicketCard({
    super.key,
    required this.ticket,
    required this.onTap,
  });

  // ── Urgency ────────────────────────────────────────────────────────────────
  Color _urgencyColor(UrgencyLevel level) {
    switch (level) {
      case UrgencyLevel.low:
        return const Color(0xFF4CAF50);
      case UrgencyLevel.medium:
        return const Color(0xFFFF9800);
      case UrgencyLevel.high:
        return const Color(0xFFF44336);
      case UrgencyLevel.critical:
        return const Color(0xFF9C27B0);
    }
  }

  String _urgencyLabel(UrgencyLevel level) {
    switch (level) {
      case UrgencyLevel.low:
        return 'LOW';
      case UrgencyLevel.medium:
        return 'MEDIUM';
      case UrgencyLevel.high:
        return 'HIGH';
      case UrgencyLevel.critical:
        return 'CRITICAL';
    }
  }

  // ── Status ─────────────────────────────────────────────────────────────────
  Color _statusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return const Color(0xFF2196F3);
      case TicketStatus.assigned:
        return const Color(0xFF00BCD4);
      case TicketStatus.pending:
        return const Color(0xFFFF9800);
      case TicketStatus.closed:
        return const Color(0xFF4CAF50);
      case TicketStatus.rejected:
        return const Color(0xFFF44336);
    }
  }

  String _statusLabel(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.assigned:
        return 'Assigned';
      case TicketStatus.pending:
        return 'Pending';
      case TicketStatus.closed:
        return 'Closed';
      case TicketStatus.rejected:
        return 'Rejected';
    }
  }

  // ── Category icon ──────────────────────────────────────────────────────────
  IconData _categoryIcon(HazardCategory cat) {
    switch (cat) {
      case HazardCategory.electrical:
        return Icons.bolt_rounded;
      case HazardCategory.chemical:
        return Icons.science_rounded;
      case HazardCategory.structural:
        return Icons.domain_rounded;
      case HazardCategory.janitorial:
        return Icons.cleaning_services_rounded;
    }
  }

  String _categoryLabel(HazardCategory cat) {
    switch (cat) {
      case HazardCategory.electrical:
        return 'Electrical';
      case HazardCategory.chemical:
        return 'Chemical';
      case HazardCategory.structural:
        return 'Structural';
      case HazardCategory.janitorial:
        return 'Janitorial';
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final urgencyColor = _urgencyColor(ticket.urgency);
    final statusColor = _statusColor(ticket.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left urgency stripe
            Container(
              width: 5,
              color: urgencyColor,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: category chip + status badge
                    Row(
                      children: [
                        Icon(
                          _categoryIcon(ticket.category),
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _categoryLabel(ticket.category),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const Spacer(),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _statusLabel(ticket.status),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Title
                    Text(
                      ticket.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            ticket.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Bottom row: urgency badge + date
                    Row(
                      children: [
                        // Urgency badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: urgencyColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _urgencyLabel(ticket.urgency),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: urgencyColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 3),
                        Text(
                          _formatDate(ticket.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Chevron
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.chevron_right, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
