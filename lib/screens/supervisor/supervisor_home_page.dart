import 'dart:async';

import 'package:flutter/material.dart';
import 'package:laporpak_fp/core/constants/enums.dart';
import 'package:laporpak_fp/core/models/app_notification.dart';
import 'package:laporpak_fp/core/models/app_user.dart';
import 'package:laporpak_fp/core/models/ticket.dart';
import 'package:laporpak_fp/core/services/firestore/firestore_notification_repository.dart';
import 'package:laporpak_fp/core/services/firestore/firestore_ticket_repository.dart';
import 'package:laporpak_fp/core/services/notification_repository.dart';
import 'package:laporpak_fp/core/services/notification_service.dart';
import 'package:laporpak_fp/screens/supervisor/supervisor_ticket_detail_page.dart';
import 'package:laporpak_fp/screens/supervisor/widgets/supervisor_ticket_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enum for sorting options
// ─────────────────────────────────────────────────────────────────────────────
enum _SortOption { dateDesc, dateAsc, urgencyHighLow, urgencyLowHigh }

// ─────────────────────────────────────────────────────────────────────────────
// SupervisorHomePage — Department Dashboard (Fitur 1)
// ─────────────────────────────────────────────────────────────────────────────
class SupervisorHomePage extends StatefulWidget {
  final AppUser user;

  const SupervisorHomePage({super.key, required this.user});

  @override
  State<SupervisorHomePage> createState() => _SupervisorHomePageState();
}

class _SupervisorHomePageState extends State<SupervisorHomePage>
    with SingleTickerProviderStateMixin {
  _SortOption _sortOption = _SortOption.dateDesc;
  TicketStatus? _filterStatus;
  late TabController _tabController;
  final _repo = FirestoreTicketRepository();
  final NotificationRepository _notifRepo = FirestoreNotificationRepository();

  StreamSubscription<List<Ticket>>? _notifSub;
  final Map<String, TicketStatus> _knownStatuses = {};
  bool _notifInitialized = false;

  static const _tabs = <String, TicketStatus?>{
    'All': null,
    'Open': TicketStatus.open,
    'Assigned': TicketStatus.assigned,
    'Pending': TicketStatus.pendingValidation,
    'Closed': TicketStatus.closed,
    'Rejected': TicketStatus.rejected,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        _filterStatus = _tabs.values.elementAt(_tabController.index);
      });
    });
    _startNotificationListener();
  }

  void _startNotificationListener() {
    _notifSub = _repo.watchByDepartment(widget.user.department).listen((tickets) {
      if (!_notifInitialized) {
        _notifInitialized = true;
        for (final t in tickets) {
          _knownStatuses[t.id] = t.status;
        }
        return;
      }
      for (final t in tickets) {
        final prev = _knownStatuses[t.id];
        if (t.status == TicketStatus.open && prev != TicketStatus.open) {
          const title = 'New Hazard Report';
          final body = '${t.workerName}: ${t.title}';
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
        } else if (t.status == TicketStatus.pendingValidation && prev != TicketStatus.pendingValidation) {
          const title = 'Resolution Submitted';
          final body = '${t.title} is ready for validation.';
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
    _tabController.dispose();
    super.dispose();
  }

  // ── Sorting logic ──────────────────────────────────────────────────────────
  int _urgencyOrder(UrgencyLevel u) {
    switch (u) {
      case UrgencyLevel.critical:
        return 0;
      case UrgencyLevel.high:
        return 1;
      case UrgencyLevel.medium:
        return 2;
      case UrgencyLevel.low:
        return 3;
    }
  }

  List<Ticket> _sorted(List<Ticket> source) {
    final list = [...source];
    switch (_sortOption) {
      case _SortOption.dateDesc:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _SortOption.dateAsc:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case _SortOption.urgencyHighLow:
        list.sort(
          (a, b) => _urgencyOrder(a.urgency).compareTo(_urgencyOrder(b.urgency)),
        );
      case _SortOption.urgencyLowHigh:
        list.sort(
          (a, b) => _urgencyOrder(b.urgency).compareTo(_urgencyOrder(a.urgency)),
        );
    }
    return list;
  }

  List<Ticket> _filtered(List<Ticket> source) {
    if (_filterStatus == null) return source;
    return source.where((t) => t.status == _filterStatus).toList();
  }

  // ── Summary counts ─────────────────────────────────────────────────────────
  Map<TicketStatus, int> _statusCounts(List<Ticket> all) {
    final Map<TicketStatus, int> map = {};
    for (final t in all) {
      map[t.status] = (map[t.status] ?? 0) + 1;
    }
    return map;
  }

  // ── Sort label ─────────────────────────────────────────────────────────────
  String _sortLabel(_SortOption o) {
    switch (o) {
      case _SortOption.dateDesc:
        return 'Newest First';
      case _SortOption.dateAsc:
        return 'Oldest First';
      case _SortOption.urgencyHighLow:
        return 'Urgency: High → Low';
      case _SortOption.urgencyLowHigh:
        return 'Urgency: Low → High';
    }
  }

  // ── Navigate to detail ─────────────────────────────────────────────────────
  void _openDetail(Ticket ticket) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SupervisorTicketDetailPage(ticket: ticket, supervisorUid: widget.user.uid),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<List<Ticket>>(
      stream: _repo.watchByDepartment(widget.user.department),
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
                    'Failed to load tickets.\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final allTickets = snapshot.data ?? [];
        final counts = _statusCounts(allTickets);
        final displayTickets = _sorted(_filtered(allTickets));

        return Column(
          children: [
            // ── Summary header ───────────────────────────────────────────────
            Container(
              color: theme.colorScheme.primary,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.department,
                    style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${allTickets.length} Total Ticket${allTickets.length != 1 ? 's' : ''}',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _SummaryChip(label: 'Open', count: counts[TicketStatus.open] ?? 0, color: const Color(0xFF2196F3)),
                        const SizedBox(width: 8),
                        _SummaryChip(label: 'Assigned', count: counts[TicketStatus.assigned] ?? 0, color: const Color(0xFF00BCD4)),
                        const SizedBox(width: 8),
                        _SummaryChip(label: 'Pending Validation', count: counts[TicketStatus.pendingValidation] ?? 0, color: const Color(0xFFFF9800)),
                        const SizedBox(width: 8),
                        _SummaryChip(label: 'Closed', count: counts[TicketStatus.closed] ?? 0, color: const Color(0xFF4CAF50)),
                        const SizedBox(width: 8),
                        _SummaryChip(label: 'Rejected',count: counts[TicketStatus.rejected] ?? 0, color: const Color(0xFFF44336)),
                      ], 
                    ),
                  ),
                ],
              ),
            ),

            // ── Sort bar ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.sort, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  const Text('Sort by:', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<_SortOption>(
                        value: _sortOption,
                        isDense: true,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                        style: TextStyle(fontSize: 13, color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                        items: _SortOption.values
                            .map((o) => DropdownMenuItem(value: o, child: Text(_sortLabel(o))))
                            .toList(),
                        onChanged: (v) { if (v != null) setState(() => _sortOption = v); },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Tab bar ──────────────────────────────────────────────────────
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: theme.colorScheme.primary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              tabs: _tabs.keys.map((label) => Tab(text: label)).toList(),
            ),

            // ── Ticket list ───────────────────────────────────────────────────
            Expanded(
              child: displayTickets.isEmpty
                  ? _EmptyState(filterStatus: _filterStatus)
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      itemCount: displayTickets.length,
                      itemBuilder: (context, index) {
                        final ticket = displayTickets[index];
                        return SupervisorTicketCard(
                          ticket: ticket,
                          onTap: () => _openDetail(ticket),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary chip widget
// ─────────────────────────────────────────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$count $label',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state widget
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final TicketStatus? filterStatus;

  const _EmptyState({required this.filterStatus});

  @override
  Widget build(BuildContext context) {
    final message = filterStatus == null
        ? 'No tickets yet.'
        : 'No ${filterStatus!.name} tickets found.';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            filterStatus == null ? Icons.inbox_outlined : Icons.filter_list_off,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey[500], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
