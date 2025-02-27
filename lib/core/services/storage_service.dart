import 'dart:developer';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> uploadImage(File image) async {
    try {
      final String fileName =
          "images/${DateTime.now().millisecondsSinceEpoch}.jpg";

      final response = await _supabase.storage
          .from('profile_images')
          .upload(
            fileName,
            image,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      log(
        "[Upload] Image uploaded successfully: $response - in the storage service",
      );

      if (response.isEmpty) {
        throw Exception('Upload failed');
      }

      final String publicUrl = _supabase.storage
          .from('profile_images')
          .getPublicUrl(fileName);
      log("Get Image URL: $publicUrl -in the storage service");
      log("return public URL");

      return publicUrl;
    } catch (e) {
      rethrow;
    }
  }
}
