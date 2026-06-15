import 'package:cloud_firestore/cloud_firestore.dart';

class ResolutionReport {
  final String completionNote;
  final String photoUrl;
  final String submittedBy;
  final DateTime submittedAt;

  const ResolutionReport({
    required this.completionNote,
    required this.photoUrl,
    required this.submittedBy,
    required this.submittedAt,
  });

  factory ResolutionReport.fromJson(Map<String, dynamic> json) {
    // submittedAt may arrive as a Firestore Timestamp OR an ISO String
    DateTime parseDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is String) return DateTime.parse(v);
      return DateTime.now();
    }

    return ResolutionReport(
      completionNote: json['completionNote'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      submittedBy: json['submittedBy'] as String? ?? '',
      submittedAt: parseDate(json['submittedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completionNote': completionNote,
      'photoUrl': photoUrl,
      'submittedBy': submittedBy,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }
}
