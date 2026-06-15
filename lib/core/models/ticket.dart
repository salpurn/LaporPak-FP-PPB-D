import '../constants/enums.dart';
import 'resolution_report.dart';

class Ticket {
  final String id;
  final String title;
  final String location;
  final String description;
  final HazardCategory category;
  final UrgencyLevel urgency;
  final TicketStatus status;
  final String department;
  final String workerId;
  final String? assigneeId;
  final String? supervisorId;
  final String workerName;
  final String workerDepartment;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ResolutionReport? resolutionReport;
  final String photoUrl;

  const Ticket({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.category,
    required this.urgency,
    required this.status,
    required this.department,
    required this.workerId,
    required this.assigneeId,
    required this.supervisorId,
    required this.workerName,
    required this.workerDepartment,
    required this.deadline,
    required this.createdAt,
    required this.updatedAt,
    required this.resolutionReport,
    this.photoUrl = '',
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    T safeEnum<T extends Enum>(List<T> values, String? raw, T fallback) {
      if (raw == null) return fallback;
      try {
        return values.byName(raw);
      } catch (_) {
        return fallback;
      }
    }

    return Ticket(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      location: json['location'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: safeEnum(HazardCategory.values, json['category'] as String?, HazardCategory.structural),
      urgency: safeEnum(UrgencyLevel.values, json['urgency'] as String?, UrgencyLevel.low),
      status: safeEnum(TicketStatus.values, json['status'] as String?, TicketStatus.open),
      department: json['department'] as String? ?? '',
      workerId: json['workerId'] as String? ?? json['reporterId'] as String? ?? '',
      assigneeId: json['assigneeId'] as String?,
      supervisorId: json['supervisorId'] as String?,
      workerName: json['workerName'] as String? ?? '',
      workerDepartment: json['workerDepartment'] as String? ?? '',
      deadline: json['deadline'] == null
          ? null
          : DateTime.tryParse(json['deadline'] as String) ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      resolutionReport: json['resolutionReport'] == null
          ? null
          : ResolutionReport.fromJson(
              json['resolutionReport'] as Map<String, dynamic>,
            ),
      photoUrl: json['photoUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'description': description,
      'category': category.name,
      'urgency': urgency.name,
      'status': status.name,
      'department': department,
      'workerId': workerId,
      'assigneeId': assigneeId,
      'supervisorId': supervisorId,
      'workerName': workerName,
      'workerDepartment': workerDepartment,
      'deadline': deadline?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'resolutionReport': resolutionReport?.toJson(),
      'photoUrl': photoUrl,
    };
  }
}
