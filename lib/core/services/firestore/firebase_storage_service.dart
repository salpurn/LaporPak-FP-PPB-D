import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:laporpak_fp/core/services/storage_service.dart';

class FirebaseStorageService implements StorageService {
  final _storage = FirebaseStorage.instance;

  @override
  Future<String> uploadPhoto({required String filePath}) async {
    final file = File(filePath);
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
    final ref = _storage.ref().child('ticket_photos/$fileName');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  @override
  Future<void> deletePhoto({required String url}) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (_) {
      // ignore — photo may already be deleted or URL is not a Storage URL
    }
  }
}
