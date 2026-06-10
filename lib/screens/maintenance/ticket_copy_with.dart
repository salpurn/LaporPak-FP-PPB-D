import 'package:laporpak_fp/core/constants/enums.dart';
import 'package:laporpak_fp/core/models/resolution_report.dart';
import 'package:laporpak_fp/core/models/ticket.dart';

const _keep = Object();

extension TicketCopyWith on Ticket {
  Ticket copyWith({
    String? id,
    String? title,
    String? location,
    String? description,
    HazardCategory? category,
    UrgencyLevel? urgency,
    TicketStatus? status,
    String? department,
    String? reporterId,
    Object? assigneeId = _keep,
    Object? supervisorId = _keep,
    Object? deadline = _keep,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? resolutionReport = _keep,
  }) {
    return Ticket(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      description: description ?? this.description,
      category: category ?? this.category,
      urgency: urgency ?? this.urgency,
      status: status ?? this.status,
      department: department ?? this.department,
      reporterId: reporterId ?? this.reporterId,
      assigneeId: identical(assigneeId, _keep) ? this.assigneeId : assigneeId as String?,
      supervisorId: identical(supervisorId, _keep) ? this.supervisorId : supervisorId as String?,
      deadline: identical(deadline, _keep) ? this.deadline : deadline as DateTime?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolutionReport: identical(resolutionReport, _keep)
          ? this.resolutionReport
          : resolutionReport as ResolutionReport?,
    );
  }
}
