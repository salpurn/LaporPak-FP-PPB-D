import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laporpak_fp/core/constants/enums.dart';
import 'package:laporpak_fp/core/models/app_user.dart';
import 'package:laporpak_fp/core/models/ticket.dart';
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
  TicketStatus? _filterStatus; // null = all
  late TabController _tabController;

  // Tabs map status filter
  static const _tabs = <String, TicketStatus?>{
    'All': null,
    'Open': TicketStatus.open,
    'Assigned': TicketStatus.assigned,
    'Pending': TicketStatus.pending,
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
  }

  @override
  void dispose() {
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
        builder: (_) => SupervisorTicketDetailPage(ticket: ticket),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Normalize department string for case-insensitive comparison
    final supervisorDept = widget.user.department.trim().toLowerCase();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tickets')
          .snapshots(),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error
        if (snapshot.hasError) {
          return Center(
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
          );
        }

        // Parse documents — robust: skip bad docs instead of crashing the whole stream
        final docs = snapshot.data?.docs ?? [];
        final allTickets = <Ticket>[];

        for (final doc in docs) {
          try {
            final data = doc.data() as Map<String, dynamic>;

            // ── Case-insensitive department filter (client-side) ──
            final ticketDept =
                (data['department'] as String? ?? '').trim().toLowerCase();
            if (ticketDept != supervisorDept) continue;

            // Recursively converts any Firestore Timestamp → ISO 8601 String
            // so that fromJson() (which uses DateTime.parse) never receives a Timestamp
            Map<String, dynamic> sanitize(Map<String, dynamic> m) {
              return m.map((key, value) {
                if (value is Timestamp) {
                  return MapEntry(key, value.toDate().toIso8601String());
                } else if (value is Map<String, dynamic>) {
                  return MapEntry(key, sanitize(value));
                }
                return MapEntry(key, value);
              });
            }

            final clean = sanitize({...data, 'id': doc.id});
            allTickets.add(Ticket.fromJson(clean));
          } catch (e) {
            // Log the bad document and continue — do not crash the whole list
            debugPrint('[SupervisorDashboard] Skipped doc ${doc.id}: $e');
          }
        }


        final counts = _statusCounts(allTickets);
        final displayTickets = _sorted(_filtered(allTickets));

        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            // ── Summary stats header ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: theme.colorScheme.primary,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.department,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${allTickets.length} Total Ticket${allTickets.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Summary chip row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _SummaryChip(
                            label: 'Open',
                            count: counts[TicketStatus.open] ?? 0,
                            color: const Color(0xFF2196F3),
                          ),
                          const SizedBox(width: 8),
                          _SummaryChip(
                            label: 'Assigned',
                            count: counts[TicketStatus.assigned] ?? 0,
                            color: const Color(0xFF00BCD4),
                          ),
                          const SizedBox(width: 8),
                          _SummaryChip(
                            label: 'Pending',
                            count: counts[TicketStatus.pending] ?? 0,
                            color: const Color(0xFFFF9800),
                          ),
                          const SizedBox(width: 8),
                          _SummaryChip(
                            label: 'Closed',
                            count: counts[TicketStatus.closed] ?? 0,
                            color: const Color(0xFF4CAF50),
                          ),
                          const SizedBox(width: 8),
                          _SummaryChip(
                            label: 'Rejected',
                            count: counts[TicketStatus.rejected] ?? 0,
                            color: const Color(0xFFF44336),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Sort bar ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.sort, size: 18, color: Colors.grey),
                    const SizedBox(width: 6),
                    const Text(
                      'Sort by:',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<_SortOption>(
                          value: _sortOption,
                          isDense: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            size: 18,
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          items: _SortOption.values
                              .map(
                                (o) => DropdownMenuItem(
                                  value: o,
                                  child: Text(_sortLabel(o)),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _sortOption = v);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Tab bar ─────────────────────────────────────────────────────
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: theme.colorScheme.primary,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  tabs: _tabs.keys
                      .map((label) => Tab(text: label))
                      .toList(),
                ),
              ),
            ),
          ],

          // ── Ticket list body ───────────────────────────────────────────────
          body: displayTickets.isEmpty
              ? _EmptyState(
                  filterStatus: _filterStatus,
                  department: widget.user.department,
                )
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
  final String department;

  const _EmptyState({required this.filterStatus, required this.department});

  @override
  Widget build(BuildContext context) {
    final message = filterStatus == null
        ? 'No tickets in $department department yet.'
        : 'No ${filterStatus!.name} tickets found.';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            filterStatus == null
                ? Icons.inbox_outlined
                : Icons.filter_list_off,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sticky tab bar delegate
// ─────────────────────────────────────────────────────────────────────────────
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: overlapsContent ? 2 : 0,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) =>
      tabBar != oldDelegate.tabBar;
}
