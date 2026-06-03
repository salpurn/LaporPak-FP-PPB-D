class AppNotification {
  final String id;
  final String recipientId;
  final String title;
  final String body;
  final String ticketId;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.recipientId,
    required this.title,
    required this.body,
    required this.ticketId,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      recipientId: json['recipientId'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      ticketId: json['ticketId'] as String,
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipientId': recipientId,
      'title': title,
      'body': body,
      'ticketId': ticketId,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
