import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:laporpak_fp/core/constants/collections.dart';
import 'package:laporpak_fp/core/constants/enums.dart';
import 'package:laporpak_fp/core/models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> register(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() {
    return _auth.signOut();
  }

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  Future<AppUser?> fetchCurrentUser() async {
    final current = _auth.currentUser;
    if (current == null) {
      return null;
    }

    final doc = await _firestore
        .collection(Collections.users)
        .doc(current.uid)
        .get();

    if (doc.exists) {
      final data = doc.data() ?? <String, dynamic>{};
      final roleValue = data['role'];
      if (roleValue is String && roleValue.isNotEmpty) {
        return AppUser.fromJson(<String, dynamic>{...data, 'uid': current.uid});
      }
    }

    final nameFallback = current.displayName?.trim().isNotEmpty == true
        ? current.displayName!.trim()
        : (current.email?.split('@').first ?? 'User');

    return AppUser(
      uid: current.uid,
      name: nameFallback,
      email: current.email ?? '',
      role: UserRole.floorWorker,
      department: '',
      fcmToken: '',
    );
  }
}
