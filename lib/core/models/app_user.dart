import '../constants/enums.dart';

class AppUser {
  final String uid;
  final String workerId;
  final String name;
  final String email;
  final UserRole role;
  final String department;
  final String fcmToken;

  const AppUser({
    required this.uid,
    required this.workerId,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.fcmToken,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final roleRaw = json['role'] as String? ?? '';
    UserRole role;
    try {
      // 'worker' was the old enum name; map it to floorWorker for existing Firestore docs
      final normalized = roleRaw == 'worker' ? 'floorWorker' : roleRaw;
      role = UserRole.values.byName(normalized);
    } catch (_) {
      role = UserRole.floorWorker;
    }

    return AppUser(
      uid: json['uid'] as String? ?? '',
      workerId: (json['workerId'] ?? json['employeeId']) as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: role,
      department: json['department'] as String? ?? '',
      fcmToken: json['fcmToken'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'workerId': workerId,
      'name': name,
      'email': email,
      'role': role.name,
      'department': department,
      'fcmToken': fcmToken,
    };
  }
}
