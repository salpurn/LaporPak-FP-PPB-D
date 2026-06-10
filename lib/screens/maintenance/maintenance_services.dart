import 'package:laporpak_fp/core/services/fake/fake_storage_service.dart';
import 'package:laporpak_fp/core/services/fake/fake_ticket_repository.dart';
import 'package:laporpak_fp/core/services/storage_service.dart';
import 'package:laporpak_fp/core/services/ticket_repository.dart';

class MaintenanceServices {
  MaintenanceServices._();

  static final MaintenanceServices instance = MaintenanceServices._();

  final TicketRepository repo = FakeTicketRepository();
  final StorageService storage = FakeStorageService();
}
