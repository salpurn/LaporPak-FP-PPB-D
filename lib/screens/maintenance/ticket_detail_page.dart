import 'package:flutter/material.dart';
import 'package:laporpak_fp/core/constants/enums.dart';
import 'package:laporpak_fp/core/models/app_user.dart';
import 'package:laporpak_fp/core/models/resolution_report.dart';
import 'package:laporpak_fp/core/models/ticket.dart';
import 'package:laporpak_fp/screens/maintenance/maintenance_services.dart';
import 'package:laporpak_fp/screens/maintenance/resolution_report_page.dart';
import 'package:laporpak_fp/core/models/ticket_copy_with.dart';
import 'package:laporpak_fp/screens/maintenance/widgets/status_badge.dart';

class TicketDetailPage extends StatelessWidget {
  final Ticket ticket;
  final AppUser user;

  const TicketDetailPage({super.key, required this.ticket, required this.user});

  bool get _canEdit =>
      ticket.status == TicketStatus.pendingValidation ||
      ticket.status == TicketStatus.rejected;

  bool get _canSubmit =>
      ticket.status == TicketStatus.assigned ||
      ticket.status == TicketStatus.rejected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Detail'),
        elevation: 0.5,
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
            if (ticket.resolutionReport != null) ...[
              const SizedBox(height: 12),
              _reportCard(context),
            ],
            const SizedBox(height: 24),
            _actionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _workerCard(BuildContext context) {
    final name = ticket.workerName.isNotEmpty ? ticket.workerName : '—';
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
                    style:
                        const TextStyle(fontSize: 12, color: Colors.grey)),
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
              children: [
                Expanded(
                  child: Text(
                    ticket.title,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
          ],
        ),
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
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            _infoRow(Icons.description_outlined, ticket.description),
            const SizedBox(height: 8),
            Row(
              children: [
                _pillLabel(_categoryLabel(ticket.category)),
                const SizedBox(width: 8),
                _pillLabel(_urgencyLabel(ticket.urgency), color: _urgencyColor(ticket.urgency)),
              ],
            ),
            if (deadline != null) ...[
              const SizedBox(height: 8),
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

  Widget _reportCard(BuildContext context) {
    final report = ticket.resolutionReport!;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Resolution Report',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey),
                ),
                const Spacer(),
                if (_canEdit)
                  TextButton.icon(
                    onPressed: () => _openReportPage(context, editMode: true),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(report.completionNote),
            if (report.photoUrl.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  report.photoUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : const SizedBox(
                          height: 200,
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
              if (_canEdit) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _confirmRemovePhoto(context),
                    icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                    label: const Text('Remove photo', style: TextStyle(color: Colors.red)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ],
            ] else if (_canEdit) ...[
              const SizedBox(height: 8),
              const Text(
                'No photo attached.',
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _actionButtons(BuildContext context) {
    if (ticket.status == TicketStatus.closed) {
      return const Center(
        child: Text('This ticket has been closed.', style: TextStyle(color: Colors.grey)),
      );
    }

    if (_canSubmit) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () => _openReportPage(context, editMode: false),
          icon: const Icon(Icons.upload_outlined),
          label: Text(
            ticket.status == TicketStatus.rejected ? 'Resubmit Report' : 'Submit Report',
          ),
        ),
      );
    }

    if (ticket.status == TicketStatus.pendingValidation) {
      return const Center(
        child: Text('Awaiting supervisor validation.', style: TextStyle(color: Colors.grey)),
      );
    }

    return const SizedBox.shrink();
  }

  void _openReportPage(BuildContext context, {required bool editMode}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResolutionReportPage(ticket: ticket, user: user, editMode: editMode),
      ),
    );
  }

  Future<void> _confirmRemovePhoto(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove photo?'),
        content: const Text(
          'The photo evidence will be permanently deleted. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final services = MaintenanceServices.instance;
    final report = ticket.resolutionReport!;

    try {
      await services.storage.deletePhoto(url: report.photoUrl);
      final cleared = ResolutionReport(
        completionNote: report.completionNote,
        photoUrl: '',
        submittedBy: report.submittedBy,
        submittedAt: report.submittedAt,
      );
      await services.repo.updateTicket(
        ticket.copyWith(resolutionReport: cleared, updatedAt: DateTime.now()),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Photo removed.')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to remove photo: $e')));
      }
    }
  }

  Widget _infoRow(IconData icon, String text, {Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: TextStyle(fontSize: 14, color: color))),
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
