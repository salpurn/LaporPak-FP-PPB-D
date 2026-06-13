import '../models/ticket.dart';

abstract class TicketRepository {
  Future<void> createTicket(Ticket ticket);
  Future<void> updateTicket(Ticket ticket);
  Future<void> deleteTicket(String id);

  Stream<List<Ticket>> watchByWorker(String uid);
  Stream<List<Ticket>> watchByDepartment(String department);
  Stream<List<Ticket>> watchByAssignee(String uid);

  Future<void> assignTicket({
    required String id,
    required String workerId,
    required DateTime deadline,
  });

  Future<void> validateTicket({required String id, required bool approved});
}
