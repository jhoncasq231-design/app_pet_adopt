import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final _uuid = const Uuid();

  // ✅ Getter seguro
  SupabaseClient get _supabase => Supabase.instance.client;

  /// Sube una imagen al bucket de Supabase y retorna la URL pública
  Future<String?> uploadPetImage(File imageFile, String userId) async {
    try {
      final fileExtension = path.extension(imageFile.path);
      final fileName = '${_uuid.v4()}$fileExtension';
      final filePath = '$userId/$fileName';

      await _supabase.storage
          .from('pet-images')
          .upload(filePath, imageFile);

      final publicUrl = _supabase.storage
          .from('pet-images')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      print('Error al subir imagen: $e');
      return null;
    }
  }

  Future<List<String>> uploadMultiplePetImages(
    List<File> imageFiles,
    String userId,
  ) async {
    final urls = <String>[];

    for (final file in imageFiles) {
      final url = await uploadPetImage(file, userId);
      if (url != null) urls.add(url);
    }

    return urls;
  }

  Future<bool> deleteImage(String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final segments = uri.pathSegments;

      final bucketIndex = segments.indexOf('pet-images');
      if (bucketIndex == -1) return false;

      final filePath = segments.sublist(bucketIndex + 1).join('/');

      await _supabase.storage
          .from('pet-images')
          .remove([filePath]);

      return true;
    } catch (e) {
      print('Error al eliminar imagen: $e');
      return false;
    }
  }

  Future<void> deleteMultipleImages(List<String> imageUrls) async {
    for (final url in imageUrls) {
      await deleteImage(url);
    }
  }

  double getFileSizeInMB(File file) {
    return file.lengthSync() / (1024 * 1024);
  }

  bool isValidImageFile(File file) {
    final ext = path.extension(file.path).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(ext);
  }

  bool isValidFileSize(File file, {double maxSizeMB = 5}) {
    return getFileSizeInMB(file) <= maxSizeMB;
  }
}
