import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

/// Firebase Storage Provider
/// Handles file uploads and downloads
class FirebaseStorageProvider {
  final FirebaseStorage _storage;
  final Uuid _uuid = const Uuid();

  FirebaseStorageProvider({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  /// Upload image file
  Future<String> uploadImage(File file, String path) async {
    try {
      final fileName = '${_uuid.v4()}.jpg';
      final ref = _storage.ref().child(path).child(fileName);

      final uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload video file
  Future<String> uploadVideo(File file, String path) async {
    try {
      final fileName = '${_uuid.v4()}.mp4';
      final ref = _storage.ref().child(path).child(fileName);

      final uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: 'video/mp4'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload video: $e');
    }
  }

  /// Upload generic file
  Future<String> uploadFile(File file, String path, String contentType) async {
    try {
      final extension = file.path.split('.').last;
      final fileName = '${_uuid.v4()}.$extension';
      final ref = _storage.ref().child(path).child(fileName);

      final uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: contentType),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Delete file by URL
  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  /// Get download URL for a file path
  Future<String> getDownloadUrl(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to get download URL: $e');
    }
  }
}
