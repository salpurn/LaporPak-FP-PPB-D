import 'package:flutter/material.dart';
import 'package:laporpak_fp/core/constants/enums.dart';
import 'package:laporpak_fp/core/models/app_user.dart';
import 'package:laporpak_fp/core/models/ticket.dart';
import 'package:laporpak_fp/screens/maintenance/widgets/status_badge.dart';
import 'package:laporpak_fp/screens/worker/worker_services.dart';
import 'package:laporpak_fp/screens/worker/worker_ticket_form_page.dart';

class WorkerTicketDetailPage extends StatelessWidget {
  final Ticket ticket;
  final AppUser user;

  const WorkerTicketDetailPage({
    super.key,
    required this.ticket,
    required this.user,
  });

  bool get _canEdit => ticket.status == TicketStatus.open;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Detail'),
        elevation: 0.5,
        actions: [
          if (_canEdit)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) =>
                      WorkerTicketFormPage(user: user, existing: ticket),
                ),
              ),
            ),
          if (_canEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFD32F2F)),
              tooltip: 'Delete',
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerCard(),
            const SizedBox(height: 12),
            _workerCard(context),
            const SizedBox(height: 12),
            _detailsCard(),
            if (ticket.photoUrl.isNotEmpty) ...[
              const SizedBox(height: 12),
              _photoCard(),
            ],
            if (!_canEdit) ...[
              const SizedBox(height: 16),
              _statusInfoBanner(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _headerCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: ticket.status),
              ],
            ),
            const SizedBox(height: 8),
            _infoRow(Icons.location_on_outlined, ticket.location),
            const SizedBox(height: 4),
            _infoRow(Icons.business_outlined, ticket.department),
            const SizedBox(height: 4),
            _infoRow(
              Icons.access_time_outlined,
              'Submitted ${_formatDate(ticket.createdAt)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _workerCard(BuildContext context) {
    final name = ticket.workerName.isNotEmpty ? ticket.workerName : '-';
    final dept = ticket.workerDepartment.isNotEmpty
        ? ticket.workerDepartment
        : ticket.department;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(dept,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(
                  'ID: ${ticket.workerId}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.person_outline, size: 18, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _detailsCard() {
    final deadline = ticket.deadline;
    final isOverdue = deadline != null &&
        deadline.isBefore(DateTime.now()) &&
        ticket.status != TicketStatus.closed;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Details',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.grey),
            ),
            const SizedBox(height: 10),
            _infoRow(Icons.description_outlined, ticket.description),
            const SizedBox(height: 10),
            Row(
              children: [
                _pillLabel(_categoryLabel(ticket.category)),
                const SizedBox(width: 8),
                _pillLabel(
                  _urgencyLabel(ticket.urgency),
                  color: _urgencyColor(ticket.urgency),
                ),
              ],
            ),
            if (deadline != null) ...[
              const SizedBox(height: 10),
              _infoRow(
                isOverdue ? Icons.warning_amber_rounded : Icons.schedule,
                'Deadline: ${_formatDate(deadline)}',
                color: isOverdue ? const Color(0xFFD32F2F) : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _photoCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Photo Evidence',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.grey),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                ticket.photoUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 220,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : const SizedBox(
                        height: 220,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                errorBuilder: (_, _, _) => const SizedBox(
                  height: 100,
                  child: Center(
                    child: Icon(Icons.broken_image_outlined, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusInfoBanner() {
    final (icon, message, color) = switch (ticket.status) {
      TicketStatus.assigned => (
          Icons.engineering_outlined,
          'This report has been assigned to a maintenance worker.',
          const Color(0xFF1976D2),
        ),
      TicketStatus.pending => (
          Icons.hourglass_top_outlined,
          'Awaiting supervisor validation.',
          const Color(0xFFF57C00),
        ),
      TicketStatus.closed => (
          Icons.check_circle_outline,
          'This report has been resolved and closed.',
          const Color(0xFF388E3C),
        ),
      TicketStatus.rejected => (
          Icons.cancel_outlined,
          'The resolution was rejected by the supervisor.',
          const Color(0xFFD32F2F),
        ),
      _ => (
          Icons.info_outline,
          '',
          Colors.grey,
        ),
    };

    if (message.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete report?'),
        content: const Text(
          'This hazard report will be permanently deleted and cannot be recovered.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final services = WorkerServices.instance;
      if (ticket.photoUrl.isNotEmpty) {
        await services.storage.deletePhoto(url: ticket.photoUrl);
      }
      await services.repo.deleteTicket(ticket.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report deleted.')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }

  Widget _infoRow(IconData icon, String text, {Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 14, color: color)),
        ),
      ],
    );
  }

  Widget _pillLabel(String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: color ?? Colors.grey.shade700),
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}'
      '  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _categoryLabel(HazardCategory c) {
    switch (c) {
      case HazardCategory.electrical: return 'Electrical';
      case HazardCategory.chemical: return 'Chemical';
      case HazardCategory.structural: return 'Structural';
      case HazardCategory.janitorial: return 'Janitorial';
    }
  }

  String _urgencyLabel(UrgencyLevel u) {
    switch (u) {
      case UrgencyLevel.low: return 'Low';
      case UrgencyLevel.medium: return 'Medium';
      case UrgencyLevel.high: return 'High';
      case UrgencyLevel.critical: return 'Critical';
    }
  }

  Color _urgencyColor(UrgencyLevel u) {
    switch (u) {
      case UrgencyLevel.low: return const Color(0xFF388E3C);
      case UrgencyLevel.medium: return const Color(0xFFF57C00);
      case UrgencyLevel.high: return const Color(0xFFE64A19);
      case UrgencyLevel.critical: return const Color(0xFFD32F2F);
    }
  }
}
