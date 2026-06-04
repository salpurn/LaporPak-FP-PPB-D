import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> register(String email, String password) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() {
    return _auth.signOut();
  }
<<<<<<< Updated upstream
=======

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
        return AppUser.fromJson(<String, dynamic>{
          ...data,
          'uid': current.uid,
          'name': data['name'] ?? current.displayName ?? 'User',
          'email': data['email'] ?? current.email ?? '',
          'department': data['department'] ?? '',
          'fcmToken': data['fcmToken'] ?? '',
        });
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
>>>>>>> Stashed changes
}
