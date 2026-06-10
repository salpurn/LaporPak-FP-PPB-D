import 'package:laporpak_fp/core/services/storage_service.dart';

class FakeStorageService implements StorageService {
  @override
  Future<String> uploadPhoto({required String filePath}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final seed = filePath.hashCode.abs() % 1000;
    return 'https://picsum.photos/seed/$seed/800/600';
  }

  @override
  Future<void> deletePhoto({required String url}) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
