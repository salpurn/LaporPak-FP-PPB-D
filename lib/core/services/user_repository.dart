import '../models/app_user.dart';

abstract class UserRepository {
  Stream<List<AppUser>> watchMaintenanceWorkers();
}
