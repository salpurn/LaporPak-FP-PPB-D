import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laporpak_fp/core/constants/collections.dart';
import 'package:laporpak_fp/core/constants/enums.dart';
import 'package:laporpak_fp/core/models/ticket.dart';
import 'package:laporpak_fp/core/services/firestore/firestore_ticket_repository.dart';
import 'package:laporpak_fp/core/services/holiday_service.dart';
import 'package:laporpak_fp/widgets/holiday_calendar_dialog.dart';

class SupervisorTicketDetailPage extends StatefulWidget {
  final Ticket ticket;

  const SupervisorTicketDetailPage({super.key, required this.ticket});

  @override
  State<SupervisorTicketDetailPage> createState() => _SupervisorTicketDetailPageState();
}

class _SupervisorTicketDetailPageState extends State<SupervisorTicketDetailPage> {
  bool _isLoading = false;
  final _ticketRepo = FirestoreTicketRepository();
  final _holidayService = NagerDateHolidayService();

  // ── Helpers ──────────────────────────────────────────────────────────────

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
        return 'Low';
      case UrgencyLevel.medium:
        return 'Medium';
      case UrgencyLevel.high:
        return 'High';
      case UrgencyLevel.critical:
        return 'Critical';
    }
  }

  Color _statusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return const Color(0xFF2196F3);
      case TicketStatus.assigned:
        return const Color(0xFF00BCD4);
      case TicketStatus.pendingValidation:
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
      case TicketStatus.pendingValidation:
        return 'pendingValidation Validation';
      case TicketStatus.closed:
        return 'Closed';
      case TicketStatus.rejected:
        return 'Rejected';
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

  String _formatDateTime(DateTime dt) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $h:$m';
  }

  // ── Actions ─────────────────────────────────────────────────────────────

  Future<void> _validateTicket(bool approved) async {
    setState(() => _isLoading = true);
    try {
      await _ticketRepo.validateTicket(id: widget.ticket.id, approved: approved);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(approved ? 'Ticket closed successfully' : 'Ticket rejected'),
          backgroundColor: approved ? Colors.green : Colors.red,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to validate: $e'), backgroundColor: Colors.red),
      );
      setState(() => _isLoading = false);
    }
  }

  void _showAssignSheet(BuildContext context, {required bool isReassign}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return _AssignWorkerSheet(
          ticket: widget.ticket,
          holidayService: _holidayService,
          ticketRepo: _ticketRepo,
          isReassign: isReassign,
        );
      },
    ).then((assigned) {
      if (assigned == true && mounted) {
        Navigator.pop(this.context); // go back to dashboard
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(widget.ticket.status);
    final urgencyColor = _urgencyColor(widget.ticket.urgency);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Ticket Detail',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.ticket.title,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                _statusLabel(widget.ticket.status),
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: statusColor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: urgencyColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning_amber_rounded, size: 15, color: urgencyColor),
                              const SizedBox(width: 5),
                              Text(
                                'Urgency: ${_urgencyLabel(widget.ticket.urgency)}',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: urgencyColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Info grid
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _InfoRow(icon: Icons.category_outlined, label: 'Category', value: _categoryLabel(widget.ticket.category)),
                        _divider(),
                        _InfoRow(icon: Icons.location_on_outlined, label: 'Location', value: widget.ticket.location),
                        _divider(),
                        _InfoRow(icon: Icons.apartment_outlined, label: 'Department', value: widget.ticket.department),
                        _divider(),
                        _InfoRow(
                          icon: Icons.person_outline,
                          label: 'Reported by',
                          value: widget.ticket.workerName.isEmpty ? '—' : widget.ticket.workerName,
                        ),
                        _divider(),
                        _InfoRow(icon: Icons.calendar_today_outlined, label: 'Submitted', value: _formatDateTime(widget.ticket.createdAt)),
                        if (widget.ticket.deadline != null) ...[
                          _divider(),
                          _InfoRow(icon: Icons.timer_outlined, label: 'Deadline', value: _formatDateTime(widget.ticket.deadline!)),
                        ],
                        if (widget.ticket.assigneeId != null && widget.ticket.assigneeId!.isNotEmpty) ...[
                          _divider(),
                          _InfoRow(icon: Icons.engineering_outlined, label: 'Assigned Worker (ID)', value: widget.ticket.assigneeId!),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Description',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.ticket.description.isEmpty ? 'No description provided.' : widget.ticket.description,
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),

                // Resolution report
                if (widget.ticket.resolutionReport != null) ...[
                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                    color: const Color(0xFFE8F5E9),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.check_circle_outline, color: Color(0xFF388E3C)),
                              SizedBox(width: 8),
                              Text(
                                'Resolution Report',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF388E3C)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.ticket.resolutionReport!.completionNote,
                            style: const TextStyle(fontSize: 14, height: 1.5),
                          ),
                          if (widget.ticket.resolutionReport!.photoUrl.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                widget.ticket.resolutionReport!.photoUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 200,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 80,
                                  color: Colors.grey[200],
                                  child: const Center(child: Icon(Icons.broken_image)),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 80), // space for bottom bar
              ],
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _divider() => const Divider(height: 20, thickness: 0.5);

  Widget? _buildBottomBar() {
    final status = widget.ticket.status;
    if (status == TicketStatus.open || status == TicketStatus.assigned) {
      final isReassign = status == TicketStatus.assigned;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))
          ],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: () => _showAssignSheet(context, isReassign: isReassign),
            icon: Icon(isReassign ? Icons.swap_horiz : Icons.assignment_ind),
            label: Text(isReassign ? 'Reassign Task' : 'Assign Task'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      );
    } else if (status == TicketStatus.pendingValidation) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _validateTicket(false),
                  icon: const Icon(Icons.close, color: Colors.red),
                  label: const Text('Reject', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _validateTicket(true),
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text('Accept'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return null;
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Bottom Sheet for Assignment ─────────────────────────────────────────────

class _AssignWorkerSheet extends StatefulWidget {
  final Ticket ticket;
  final HolidayService holidayService;
  final FirestoreTicketRepository ticketRepo;
  final bool isReassign;

  const _AssignWorkerSheet({
    required this.ticket,
    required this.holidayService,
    required this.ticketRepo,
    required this.isReassign,
  });

  @override
  State<_AssignWorkerSheet> createState() => _AssignWorkerSheetState();
}

class _AssignWorkerSheetState extends State<_AssignWorkerSheet> {
  bool _isLoading = false;
  String? _selectedWorkerId;
  DateTime? _selectedDeadline;
  bool _isHoliday = false;

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final sheetContext = context;
    final picked = await showDialog<DateTime>(
      context: sheetContext,
      builder: (context) => HolidayCalendarDialog(
        initialDate: _selectedDeadline ?? now.add(const Duration(days: 1)),
        firstDate: firstDate,
        lastDate: firstDate.add(const Duration(days: 365)),
        holidayService: widget.holidayService,
      ),
    );

    if (picked != null) {
      // Prompt for time
      if (!sheetContext.mounted) return;
      final time = await showTimePicker(
        context: sheetContext,
        initialTime: TimeOfDay.now(),
      );

      if (time != null && mounted) {
        final finalDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );
        setState(() {
          _selectedDeadline = finalDateTime;
          _isHoliday = false;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (_selectedWorkerId == null || _selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a worker and a deadline.')),
      );
      return;
    }

    try {
      if (await widget.holidayService.isPublicHoliday(_selectedDeadline!)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tanggal merah tidak bisa dipilih sebagai deadline.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isHoliday = true);
        return;
      }
    } catch (e) {
      debugPrint('Failed to re-check holiday: $e');
    }

    setState(() => _isLoading = true);
    try {
      await widget.ticketRepo.assignTicket(
        id: widget.ticket.id,
        workerId: _selectedWorkerId!,
        deadline: _selectedDeadline!,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket assigned successfully'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to assign: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isReassign ? 'Reassign Task' : 'Assign Task',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Ticket: ${widget.ticket.title}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          const Text('Select Maintenance Worker', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(Collections.users)
                .where('role', isEqualTo: UserRole.maintenance.name)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Error loading workers');
              }
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              
              final workers = snapshot.data!.docs;
              if (workers.isEmpty) {
                return const Text('No maintenance workers found.', style: TextStyle(color: Colors.red));
              }

              return DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                hint: const Text('Choose a worker'),
                initialValue: _selectedWorkerId,
                items: workers.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['name'] ?? 'Unknown';
                  final dept = data['department'] ?? 'Unknown';
                  return DropdownMenuItem(
                    value: doc.id,
                    child: Text('$name ($dept)'),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedWorkerId = val);
                },
              );
            },
          ),

          const SizedBox(height: 20),

          const Text('Set Deadline', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickDeadline,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedDeadline == null
                          ? 'Select date and time'
                          : '${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year} ${_selectedDeadline!.hour.toString().padLeft(2, '0')}:${_selectedDeadline!.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedDeadline == null ? Colors.grey : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isHoliday) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Warning: The selected date is an Indonesian public holiday. Please ensure the worker is available.',
                      style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(widget.isReassign ? 'Confirm Reassignment' : 'Assign Worker', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
