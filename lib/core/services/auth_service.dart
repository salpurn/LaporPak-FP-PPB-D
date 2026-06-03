import '../models/app_user.dart';

abstract class AuthService {
  Future<AppUser> signIn({required String email, required String password});
  Future<void> signOut();
  AppUser? currentUser();
  Stream<AppUser?> watchAuthState();
}
