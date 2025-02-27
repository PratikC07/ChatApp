import 'dart:developer';

import 'package:chat_app/core/models/user_model.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:flutter/widgets.dart';

class UserProvider extends ChangeNotifier {
  final DatabaseService _db;

  UserModel? _currentUser;
  UserModel? get user => _currentUser;

  UserProvider(this._db);

  // loadUser(String uid) async {
  //   log("Loading user with UID: $uid");
  //   final userData = await _db.loadUser(uid);

  //   if (userData != null) {
  //     _currentUser = UserModel.fromMap(userData);
  //     log("User loaded: ${_currentUser?.name}");
  //     notifyListeners();
  //   } else {
  //     log("User data is null");
  //   }
  // }

  loadUser(String uid) async {
    log("inside loadUser - UserProvider");
    log("Loading user with UID: $uid");
    log('calling database service loadUser func');
    final userData = await _db.loadUser(uid);

    if (userData != null) {
      log("userdata is fetch from database- using database service loadUser");
      _currentUser = UserModel.fromMap(userData);
      log(
        "User loaded successfully: ${_currentUser?.name}- currentUser is set !!!!",
      );
      notifyListeners();
    } else {
      log(
        "[Error] User data is still null! Retrying in 2 seconds...- currentUser is not set properly",
      );
      await Future.delayed(Duration(seconds: 2));
      log("calling loadUser again in the user Provider ");
      loadUser(uid); // Retry fetching user data
    }
  }

  clearUser() {
    _currentUser = null;
    log("currentUser set to null");
    notifyListeners();
  }
}
