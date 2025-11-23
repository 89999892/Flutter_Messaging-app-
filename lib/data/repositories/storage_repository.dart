import 'dart:io';
import '../providers/firebase_storage_provider.dart';

/// Storage Repository
/// Abstracts file storage operations
abstract class StorageRepository {
  Future<String> uploadImage(File file, String path);
  Future<String> uploadVideo(File file, String path);
  Future<String> uploadFile(File file, String path, String contentType);
  Future<void> deleteFile(String url);
}

/// Implementation of StorageRepository
class StorageRepositoryImpl implements StorageRepository {
  final FirebaseStorageProvider _storageProvider;

  StorageRepositoryImpl(this._storageProvider);

  @override
  Future<String> uploadImage(File file, String path) async {
    return await _storageProvider.uploadImage(file, path);
  }

  @override
  Future<String> uploadVideo(File file, String path) async {
    return await _storageProvider.uploadVideo(file, path);
  }

  @override
  Future<String> uploadFile(File file, String path, String contentType) async {
    return await _storageProvider.uploadFile(file, path, contentType);
  }

  @override
  Future<void> deleteFile(String url) async {
    await _storageProvider.deleteFile(url);
  }
}
