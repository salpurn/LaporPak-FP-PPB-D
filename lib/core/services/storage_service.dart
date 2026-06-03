abstract class StorageService {
  Future<String> uploadPhoto({required String filePath});
  Future<void> deletePhoto({required String url});
}
