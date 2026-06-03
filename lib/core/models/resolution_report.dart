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
    return ResolutionReport(
      completionNote: json['completionNote'] as String,
      photoUrl: json['photoUrl'] as String,
      submittedBy: json['submittedBy'] as String,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
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
