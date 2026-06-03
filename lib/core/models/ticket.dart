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
  final String reporterId;
  final String? assigneeId;
  final String? supervisorId;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ResolutionReport? resolutionReport;

  const Ticket({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.category,
    required this.urgency,
    required this.status,
    required this.department,
    required this.reporterId,
    required this.assigneeId,
    required this.supervisorId,
    required this.deadline,
    required this.createdAt,
    required this.updatedAt,
    required this.resolutionReport,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as String,
      title: json['title'] as String,
      location: json['location'] as String,
      description: json['description'] as String,
      category: HazardCategory.values.byName(json['category'] as String),
      urgency: UrgencyLevel.values.byName(json['urgency'] as String),
      status: TicketStatus.values.byName(json['status'] as String),
      department: json['department'] as String,
      reporterId: json['reporterId'] as String,
      assigneeId: json['assigneeId'] as String?,
      supervisorId: json['supervisorId'] as String?,
      deadline: json['deadline'] == null
          ? null
          : DateTime.parse(json['deadline'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      resolutionReport: json['resolutionReport'] == null
          ? null
          : ResolutionReport.fromJson(
              json['resolutionReport'] as Map<String, dynamic>,
            ),
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
      'reporterId': reporterId,
      'assigneeId': assigneeId,
      'supervisorId': supervisorId,
      'deadline': deadline?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'resolutionReport': resolutionReport?.toJson(),
    };
  }
}
