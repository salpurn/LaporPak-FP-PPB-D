import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laporpak_fp/core/constants/collections.dart';
import 'package:laporpak_fp/core/models/app_notification.dart';
import 'package:laporpak_fp/core/services/notification_repository.dart';

class FirestoreNotificationRepository implements NotificationRepository {
  final _col = FirebaseFirestore.instance.collection(Collections.notifications);

  @override
  Stream<List<AppNotification>> watchForUser(String uid) => _col
      .where('recipientId', isEqualTo: uid)
      .snapshots()
      .map((s) {
        final list = s.docs.map((doc) {
          final data = doc.data();
          final createdAt = data['createdAt'];
          return AppNotification.fromJson({
            ...data,
            'id': doc.id,
            'createdAt': createdAt is Timestamp
                ? createdAt.toDate().toIso8601String()
                : createdAt as String? ?? DateTime.now().toIso8601String(),
          });
        }).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });

  @override
  Future<void> add(AppNotification notification) async {
    final doc = _col.doc();
    await doc.set({...notification.toJson(), 'id': doc.id});
  }

  @override
  Future<void> delete(String id) => _col.doc(id).delete();
}
