import 'package:chat_app/core/models/user_model.dart';
import 'package:chat_app/core/other/base_viewmodel.dart';
import 'package:chat_app/core/services/database_service.dart';

class HomeViewmodel extends BaseViewmodel {
  final DatabaseService _db;

  UserModel? user;

  HomeViewmodel(this._db);
}
