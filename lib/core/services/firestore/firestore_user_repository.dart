import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laporpak_fp/core/constants/collections.dart';
import 'package:laporpak_fp/core/constants/enums.dart';
import 'package:laporpak_fp/core/models/app_user.dart';
import 'package:laporpak_fp/core/services/user_repository.dart';

class FirestoreUserRepository implements UserRepository {
  final _col = FirebaseFirestore.instance.collection(Collections.users);

  @override
  Stream<List<AppUser>> watchMaintenanceWorkers() => _col
      .where('role', isEqualTo: UserRole.maintenance.name)
      .snapshots()
      .map((s) => s.docs.map((doc) {
            final data = doc.data();
            return AppUser.fromJson({...data, 'uid': doc.id});
          }).toList());
}
