import 'dart:developer';
import 'dart:io';

import 'package:chat_app/core/enums/enums.dart';
import 'package:chat_app/core/models/user_model.dart';
import 'package:chat_app/core/other/base_viewmodel.dart';
import 'package:chat_app/core/services/auth_service.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:chat_app/core/services/storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class SignupViewmodel extends BaseViewmodel {
  final AuthService _auth;
  final DatabaseService _db;
  final SupabaseStorageService _storage;
  SignupViewmodel(this._auth, this._db, this._storage);

  String _name = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';

  final _picker = ImagePicker();

  File? _image;
  File? get image => _image;

  pickImage() async {
    log("Pick Image");

    final pic = await _picker.pickImage(source: ImageSource.gallery);

    if (pic != null) {
      _image = File(pic.path);
      notifyListeners();
    }
  }

  setName(String value) {
    _name = value;
    notifyListeners();

    log("name: $_name");
  }

  setEmail(String value) {
    _email = value;
    notifyListeners();

    log("email: $_email");
  }

  setPassword(String value) {
    _password = value;
    notifyListeners();

    log("password: $_password");
  }

  setConfirmPassword(String value) {
    _confirmPassword = value;
    notifyListeners();

    log("confirm password: $_confirmPassword");
  }

  save(Map<String, dynamic> data) async {
    await _db.saveUser(data);
  }

  signup() async {
    String? downloadUrl;
    setState(ViewState.loading);
    try {
      if (_password != _confirmPassword) {
        throw Exception("The password do not match");
      }
      log("calling signup from signup_viewmodel");
      final user = await _auth.signup(_email, _password);
      log("checking user is null or created =>$user");
      if (user != null) {
        if (_image != null) {
          log(
            "user is not null, calling uploadImage func in the signup_viewmodel",
          );
          downloadUrl = await _storage.uploadImage(_image!);
        }
        UserModel userData = UserModel(
          uid: user.uid,
          name: _name,
          email: _email,
          imageUrl: downloadUrl ?? "null",
        );
        log("creating the UserModel object with public URL");
        log("calling database service saveUser func in the signup_viewmodel");
        await _db.saveUser(userData.toMap());
        log(
          'UserModel data is stored in the fire Collection -${userData.toString()} - last log in the signup_viewmodel',
        );

        // 4️⃣ Force Firebase to update the user session so `authStateChanges()` gets latest data
        await FirebaseAuth.instance.currentUser?.reload();
        log("Firebase Auth reloaded to fetch latest user data!");
      }
      setState(ViewState.idle);
    } on FirebaseAuthException catch (e) {
      log("Error: ${e.message}");
      setState(ViewState.idle);
      rethrow;
    } catch (e) {
      log('Error: ${e.toString()}');
      setState(ViewState.idle);
      rethrow;
    }
  }
}
