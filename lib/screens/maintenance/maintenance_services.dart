import 'package:laporpak_fp/core/services/firestore/firebase_storage_service.dart';
import 'package:laporpak_fp/core/services/firestore/firestore_ticket_repository.dart';
import 'package:laporpak_fp/core/services/storage_service.dart';
import 'package:laporpak_fp/core/services/ticket_repository.dart';

class MaintenanceServices {
  MaintenanceServices._();

  static final MaintenanceServices instance = MaintenanceServices._();

  final TicketRepository repo = FirestoreTicketRepository();
  final StorageService storage = FirebaseStorageService();
}
