import 'package:flutter/material.dart';
import 'package:laporpak_fp/core/constants/enums.dart';

class StatusBadge extends StatelessWidget {
  final TicketStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color get _color {
    switch (status) {
      case TicketStatus.open:
        return const Color(0xFF607D8B);
      case TicketStatus.assigned:
        return const Color(0xFF1976D2);
      case TicketStatus.pendingValidation:
        return const Color(0xFFF57C00);
      case TicketStatus.closed:
        return const Color(0xFF388E3C);
      case TicketStatus.rejected:
        return const Color(0xFFD32F2F);
    }
  }

  String get _label {
    switch (status) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.assigned:
        return 'Assigned';
      case TicketStatus.pendingValidation:
        return 'pendingValidation Validation';
      case TicketStatus.closed:
        return 'Closed';
      case TicketStatus.rejected:
        return 'Rejected';
    }
  }
}
