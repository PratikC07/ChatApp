import 'dart:developer';
import 'dart:io';

import 'package:chat_app/core/other/base_viewmodel.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:chat_app/core/services/storage_service.dart';
import 'package:chat_app/ui/screens/other/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileViewmodel extends BaseViewmodel {
  final SupabaseStorageService _storage;
  final DatabaseService _database;

  ProfileViewmodel(this._storage, this._database);

  File? _image;
  File? get image => _image;

  String _name = '';
  String get name => _name;

  String _email = '';
  String get email => _email;

  String _imageUrl = '';
  String get imageUrl => _imageUrl;

  final _picker = ImagePicker();

  void setUserData(String name, String email, String imageUrl) {
    _name = name;
    _email = email;
    _imageUrl = imageUrl;
    notifyListeners();
  }

  Future<void> pickImage() async {
    try {
      log("Pick Image");

      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        _image = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      log("Error picking image: $e");
    }
  }

  updateProfileImage(String userId, BuildContext context) async {
    String? UploadedImageUrl = _imageUrl;
    try {
      if (_image != null) {
        UploadedImageUrl = await _storage.uploadImage(_image!);
        log("Image Url: $UploadedImageUrl");
      }
      await _database.updateUserInfo(userId, name, email, UploadedImageUrl!);
      _imageUrl = UploadedImageUrl;
      _image = null;
      notifyListeners();

      final userProvider = context.read<UserProvider>();
      userProvider.updateUser(name, email, imageUrl);
      log("Profile updated successfully!");
    } catch (e) {
      log("Error updating profile: $e");
      rethrow;
    }
  }
}
