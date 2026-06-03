import '../constants/enums.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String department;
  final String fcmToken;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.fcmToken,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.values.byName(json['role'] as String),
      department: json['department'] as String,
      fcmToken: json['fcmToken'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role.name,
      'department': department,
      'fcmToken': fcmToken,
    };
  }
}
