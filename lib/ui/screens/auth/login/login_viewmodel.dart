import 'dart:developer';

import 'package:chat_app/core/enums/enums.dart';
import 'package:chat_app/core/other/base_viewmodel.dart';
import 'package:chat_app/core/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginViewmodel extends BaseViewmodel {
  final AuthService _auth;

  LoginViewmodel(this._auth);

  String _email = '';
  String _password = '';

  setEmail(String value) {
    _email = value;
    notifyListeners();

    log("Email: $_email");
  }

  setPassword(String value) {
    _password = value;
    notifyListeners();

    log("Password: $_password");
  }

  login() async {
    try {
      setState(ViewState.loading);
      await _auth.login(_email, _password);
    } on FirebaseAuthException catch (e) {
      log("Error: ${e.message}");
      setState(ViewState.idle);
      rethrow;
    } catch (e) {
      log('Error : ${e.toString()}');
      setState(ViewState.idle);
      rethrow;
    }
  }
}
