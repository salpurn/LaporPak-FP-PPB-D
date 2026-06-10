import 'dart:async';

import 'package:laporpak_fp/core/constants/enums.dart';
import 'package:laporpak_fp/core/models/ticket.dart';
import 'package:laporpak_fp/core/services/ticket_repository.dart';

class FakeTicketRepository implements TicketRepository {
  final List<Ticket> _tickets = [
    Ticket(
      id: 't1',
      title: 'Frayed electrical cable near pump station',
      location: 'Kertajaya — Pump Room',
      description: 'Cable insulation worn through, sparking observed during shift change.',
      category: HazardCategory.electrical,
      urgency: UrgencyLevel.critical,
      status: TicketStatus.assigned,
      department: 'kertajaya',
      reporterId: '3YcqRVOhAtPXPUGFpBoRoRTY9FB2',
      assigneeId: 'J7p35IDXBrMNSEXpHSxTqhEYA2o1',
      supervisorId: 'QGGtk3G6OOUA1sx51H7rmO2xHYU2',
      deadline: DateTime.now().add(const Duration(hours: 6)),
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      resolutionReport: null,
    ),
    Ticket(
      id: 't2',
      title: 'Chemical spill near mixing tank',
      location: 'Perumdos — Chemical Storage',
      description: 'Solvent spill approximately 2m² on concrete floor.',
      category: HazardCategory.chemical,
      urgency: UrgencyLevel.high,
      status: TicketStatus.assigned,
      department: 'perumdos',
      reporterId: '3YcqRVOhAtPXPUGFpBoRoRTY9FB2',
      assigneeId: 'J7p35IDXBrMNSEXpHSxTqhEYA2o1',
      supervisorId: 'QGGtk3G6OOUA1sx51H7rmO2xHYU2',
      deadline: DateTime.now().subtract(const Duration(hours: 3)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      resolutionReport: null,
    ),
    Ticket(
      id: 't3',
      title: 'Loose ceiling panel in cafeteria',
      location: 'Sukolilo — Cafeteria',
      description: 'Structural panel hanging loose, risk of falling.',
      category: HazardCategory.structural,
      urgency: UrgencyLevel.medium,
      status: TicketStatus.pendingValidation,
      department: 'sukolilo',
      reporterId: '3YcqRVOhAtPXPUGFpBoRoRTY9FB2',
      assigneeId: 'J7p35IDXBrMNSEXpHSxTqhEYA2o1',
      supervisorId: 'QGGtk3G6OOUA1sx51H7rmO2xHYU2',
      deadline: DateTime.now().add(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      resolutionReport: null,
    ),
    Ticket(
      id: 't4',
      title: 'Blocked emergency exit — resubmission required',
      location: 'Kertajaya — Exit Corridor',
      description: 'Storage boxes blocking fire exit. Supervisor rejected: photo insufficient.',
      category: HazardCategory.structural,
      urgency: UrgencyLevel.high,
      status: TicketStatus.rejected,
      department: 'kertajaya',
      reporterId: '3YcqRVOhAtPXPUGFpBoRoRTY9FB2',
      assigneeId: 'J7p35IDXBrMNSEXpHSxTqhEYA2o1',
      supervisorId: 'QGGtk3G6OOUA1sx51H7rmO2xHYU2',
      deadline: DateTime.now().add(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
      resolutionReport: null,
    ),
    Ticket(
      id: 't5',
      title: 'Leaking roof gutter above workstation',
      location: 'Perumdos — Office Wing',
      description: 'Water drip near electrical outlets. Fixed and validated.',
      category: HazardCategory.structural,
      urgency: UrgencyLevel.low,
      status: TicketStatus.closed,
      department: 'perumdos',
      reporterId: '3YcqRVOhAtPXPUGFpBoRoRTY9FB2',
      assigneeId: 'J7p35IDXBrMNSEXpHSxTqhEYA2o1',
      supervisorId: 'QGGtk3G6OOUA1sx51H7rmO2xHYU2',
      deadline: DateTime.now().subtract(const Duration(days: 5)),
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      resolutionReport: null,
    ),
  ];

  final _controller = StreamController<List<Ticket>>.broadcast();

  void _emit() => _controller.add(List.unmodifiable(_tickets));

  @override
  Stream<List<Ticket>> watchByAssignee(String uid) {
    Future.microtask(_emit);
    return _controller.stream.map(
      (list) => list.where((t) => t.assigneeId == uid).toList(),
    );
  }

  @override
  Future<void> updateTicket(Ticket ticket) async {
    final index = _tickets.indexWhere((t) => t.id == ticket.id);
    if (index != -1) {
      _tickets[index] = ticket;
      _emit();
    }
  }

  @override
  Future<void> createTicket(Ticket ticket) async {
    _tickets.add(ticket);
    _emit();
  }

  @override
  Future<void> deleteTicket(String id) async {
    _tickets.removeWhere((t) => t.id == id);
    _emit();
  }

  @override
  Stream<List<Ticket>> watchByReporter(String uid) {
    Future.microtask(_emit);
    return _controller.stream.map(
      (list) => list.where((t) => t.reporterId == uid).toList(),
    );
  }

  @override
  Stream<List<Ticket>> watchByDepartment(String department) {
    Future.microtask(_emit);
    return _controller.stream.map(
      (list) => list.where((t) => t.department == department).toList(),
    );
  }

  @override
  Future<void> assignTicket({
    required String id,
    required String workerId,
    required DateTime deadline,
  }) async {
    final index = _tickets.indexWhere((t) => t.id == id);
    if (index != -1) {
      final t = _tickets[index];
      _tickets[index] = Ticket(
        id: t.id,
        title: t.title,
        location: t.location,
        description: t.description,
        category: t.category,
        urgency: t.urgency,
        status: TicketStatus.assigned,
        department: t.department,
        reporterId: t.reporterId,
        assigneeId: workerId,
        supervisorId: t.supervisorId,
        deadline: deadline,
        createdAt: t.createdAt,
        updatedAt: DateTime.now(),
        resolutionReport: t.resolutionReport,
      );
      _emit();
    }
  }

  @override
  Future<void> validateTicket({required String id, required bool approved}) async {
    final index = _tickets.indexWhere((t) => t.id == id);
    if (index != -1) {
      final t = _tickets[index];
      _tickets[index] = Ticket(
        id: t.id,
        title: t.title,
        location: t.location,
        description: t.description,
        category: t.category,
        urgency: t.urgency,
        status: approved ? TicketStatus.closed : TicketStatus.rejected,
        department: t.department,
        reporterId: t.reporterId,
        assigneeId: t.assigneeId,
        supervisorId: t.supervisorId,
        deadline: t.deadline,
        createdAt: t.createdAt,
        updatedAt: DateTime.now(),
        resolutionReport: t.resolutionReport,
      );
      _emit();
    }
  }

  void dispose() => _controller.close();
}
