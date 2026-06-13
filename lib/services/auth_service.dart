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

  Future<UserCredential> register({
    required String workerId,
    required String name,
    required String email,
    required String password,
    required UserRole role,
    required String department,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _firestore
        .collection(Collections.users)
        .doc(credential.user!.uid)
        .set({
      'uid': credential.user!.uid,
      'workerId': workerId,
      'name': name,
      'email': email,
      'role': role.name,
      'department': department,
      'fcmToken': '',
    });
    return credential;
  }

  Future<void> updateProfile({
    required String uid,
    required String workerId,
    required String name,
    required UserRole role,
    required String department,
  }) {
    return _firestore.collection(Collections.users).doc(uid).set({
      'uid': uid,
      'workerId': workerId,
      'name': name,
      'role': role.name,
      'department': department,
    }, SetOptions(merge: true));
  }

  Future<void> signOut() {
    return _auth.signOut();
  }

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  Future<AppUser?> fetchCurrentUser() async {
    final current = _auth.currentUser;
    if (current == null) return null;

    final doc = await _firestore
        .collection(Collections.users)
        .doc(current.uid)
        .get();

    if (doc.exists) {
      final data = doc.data() ?? <String, dynamic>{};
      final roleValue = data['role'];
      if (roleValue is String && roleValue.isNotEmpty) {
        return AppUser.fromJson(<String, dynamic>{
          ...data,
          'uid': current.uid,
          'name': data['name'] ?? current.displayName ?? 'User',
          'email': data['email'] ?? current.email ?? '-',
          'department': data['department'] ?? '-',
          'fcmToken': data['fcmToken'] ?? '-',
        });
      }
    }

    final nameFallback = current.displayName?.trim().isNotEmpty == true
        ? current.displayName!.trim()
        : (current.email?.split('@').first ?? 'User');

    return AppUser(
      uid: current.uid,
      workerId: '',
      name: nameFallback,
      email: current.email ?? '',
      role: UserRole.worker,
      department: '',
      fcmToken: '',
    );
  }
}
