import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laporpak_fp/core/constants/collections.dart';
import 'package:laporpak_fp/core/constants/enums.dart';
import 'package:laporpak_fp/core/models/ticket.dart';
import 'package:laporpak_fp/core/services/ticket_repository.dart';

class FirestoreTicketRepository implements TicketRepository {
  final _col = FirebaseFirestore.instance.collection(Collections.tickets);

  Ticket _fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Ticket.fromJson({
      ...data,
      'id': doc.id,
      'createdAt': _toIso(data['createdAt']),
      'updatedAt': _toIso(data['updatedAt']),
      'deadline': data['deadline'] == null ? null : _toIso(data['deadline']),
    });
  }

  String _toIso(dynamic value) {
    if (value is Timestamp) return value.toDate().toIso8601String();
    return value as String? ?? DateTime.now().toIso8601String();
  }

  @override
  Future<void> createTicket(Ticket ticket) =>
      _col.doc(ticket.id).set(ticket.toJson());

  @override
  Future<void> updateTicket(Ticket ticket) =>
      _col.doc(ticket.id).update(ticket.toJson());

  @override
  Future<void> deleteTicket(String id) => _col.doc(id).delete();

  @override
  Stream<List<Ticket>> watchByWorker(String uid) => _col
      .where('workerId', isEqualTo: uid)
      .snapshots()
      .map((s) => s.docs.map(_fromDoc).toList());

  @override
  Stream<List<Ticket>> watchByDepartment(String department) => _col
      .where('department', isEqualTo: department)
      .snapshots()
      .map((s) => s.docs.map(_fromDoc).toList());

  @override
  Stream<List<Ticket>> watchByAssignee(String uid) => _col
      .where('assigneeId', isEqualTo: uid)
      .snapshots()
      .map((s) => s.docs.map(_fromDoc).toList());

  @override
  Future<void> assignTicket({
    required String id,
    required String workerId,
    required String supervisorId,
    required DateTime deadline,
  }) =>
      _col.doc(id).update({
        'assigneeId': workerId,
        'supervisorId': supervisorId,
        'deadline': deadline.toIso8601String(),
        'status': TicketStatus.assigned.name,
        'updatedAt': DateTime.now().toIso8601String(),
      });

  @override
  Future<void> validateTicket({required String id, required bool approved}) =>
      _col.doc(id).update({
        'status': approved ? TicketStatus.closed.name : TicketStatus.rejected.name,
        'updatedAt': DateTime.now().toIso8601String(),
      });
}
