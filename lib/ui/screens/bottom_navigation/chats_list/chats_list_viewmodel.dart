import 'dart:developer';
import 'dart:async';

import 'package:chat_app/core/enums/enums.dart';
import 'package:chat_app/core/models/user_model.dart';
import 'package:chat_app/core/other/base_viewmodel.dart';
import 'package:chat_app/core/services/database_service.dart';

class ChatsListViewmodel extends BaseViewmodel {
  final DatabaseService _db;
  final UserModel _currentUser;
  Timer? _timer; // Timer instance for periodic updates

  ChatsListViewmodel(this._db, this._currentUser) {
    fetchChats();
    fetchUsers();
    _startAutoRefresh(); // Start auto-refresh for timestamps
  }

  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];

  List<UserModel> get users => _users;
  List<UserModel> get filteredUsers => _filteredUsers;

  //////////////
  List<Map<String, dynamic>> _chatRooms = [];
  List<Map<String, dynamic>> get chatRooms => _chatRooms;

  List<Map<String, dynamic>> _filteredChatRooms = [];
  List<Map<String, dynamic>> get filteredChatRooms => _filteredChatRooms;

  search(String value) {
    _filteredUsers =
        _users.where((e) => e.name.toLowerCase().contains(value)).toList();
    notifyListeners();
  }

  // searchChats(String value) {
  //   _filteredChatRooms =
  //       _chatRooms.where((chatRoom) {
  //         // Extract users map
  //         final usersMap = chatRoom['users'] as Map<String, dynamic>;

  //         // Get the other user by filtering out the current user
  //         usersMap.remove(_currentUser.uid);
  //         final otherUser = UserModel.fromMap(usersMap.values.first);

  //         // Get last message content
  //         final lastMessage = chatRoom["lastMessage"]?["content"] ?? "";

  //         return otherUser.name.toLowerCase().contains(value.toLowerCase()) ||
  //             lastMessage.toLowerCase().contains(value.toLowerCase());
  //       }).toList();

  //   // log("###########FilterChats: $_filteredChatRooms");

  //   notifyListeners();
  // }

  searchChats(String value) {
    _filteredChatRooms =
        _chatRooms.where((chatRoom) {
          final usersMap = Map<String, dynamic>.from(
            chatRoom['users'],
          ); // Clone map

          // Get the other user by filtering out the current user
          usersMap.remove(_currentUser.uid);
          if (usersMap.isEmpty) return false; // Safety check

          final otherUser = UserModel.fromMap(usersMap.values.first);
          final lastMessage = chatRoom["lastMessage"]?["content"] ?? "";

          return otherUser.name.toLowerCase().contains(value.toLowerCase()) ||
              lastMessage.toLowerCase().contains(value.toLowerCase());
        }).toList();

    notifyListeners();
  }

  fetchUserModel(String userId) async {
    try {
      Map<String, dynamic>? userData = await _db.fetchUser(userId);
      if (userData != null) {
        return userData;
      }
    } catch (e) {
      log("Error while fetching userModel data: $e");
      rethrow;
    }
  }

  fetchChats() async {
    try {
      setState(ViewState.loading);

      // 2️⃣ Fetch existing chat rooms
      _db.getChatRooms(_currentUser.uid).listen((data) {
        _chatRooms =
            data.docs.map((e) => e.data()).toList(); // Array of objects

        // **Sort chats based on lastMessage.timestamp in descending order**
        _chatRooms.sort((a, b) {
          int timeA = a["lastMessage"]?["timestamp"] ?? 0;
          int timeB = b["lastMessage"]?["timestamp"] ?? 0;
          return timeB.compareTo(timeA); // Sort latest messages first
        });
        _filteredChatRooms = _chatRooms;
        // log("################ChatData : $_chatRooms");
        log("################FilteredChatData : $_filteredChatRooms");

        // log("_chatRooms: //////////////////////////////$_chatRooms");
        setState(ViewState.idle);
        notifyListeners();
      });
    } catch (e) {
      setState(ViewState.idle);
      log("Error Fetching Users: $e");
    }
  }

  fetchUsers() async {
    try {
      setState(ViewState.loading);

      _db.fetchUserStream(_currentUser.uid).listen((data) {
        _users = data.docs.map((e) => UserModel.fromMap(e.data())).toList();
        _filteredUsers = users;
        log("#################Filtered Users: $_filteredUsers");
        setState(ViewState.idle);
        notifyListeners();
      });
    } catch (e) {
      log("Error while fetching new users: $e");
      rethrow;
    }
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      log("//////////Start Auto Refresh is called");
      notifyListeners(); // This will rebuild the UI every minute
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Stop the timer when the viewmodel is disposed
    super.dispose();
  }
}
