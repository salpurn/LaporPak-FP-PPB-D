import '../models/app_notification.dart';

abstract class NotificationRepository {
  Stream<List<AppNotification>> watchForUser(String uid);
  Future<void> add(AppNotification notification);
  Future<void> delete(String id);
}
