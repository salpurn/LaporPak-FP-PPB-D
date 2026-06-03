import '../models/app_notification.dart';

abstract class NotificationService {
  Future<void> sendToUser({
    required String uid,
    required String title,
    required String body,
    required String ticketId,
  });
  Stream<List<AppNotification>> watchInbox(String uid);
  Future<void> markAsRead(String id);
}
