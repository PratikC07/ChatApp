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

  search(String value) {
    _filteredUsers =
        _users.where((e) => e.name.toLowerCase().contains(value)).toList();
    notifyListeners();
  }

  // fetchUsers() async {
  //   try {
  //   setState(ViewState.loading);
  //     final res = await _db.fetchUsers(_currentUser.uid);
  //     _users =
  //         res.map((e) => UserModel.fromMap(e)).toList(); // convert to UserModel
  //     _filteredUsers = _users;
  //     notifyListeners();
  //     setState(ViewState.idle);
  //   } catch (e) {
  //     setState(ViewState.idle);
  //     log("Error Fetching Users: $e");
  //   }
  // }

  fetchUsers() async {
    try {
      setState(ViewState.loading);
      // final res = await _db.fetchUsers(_currentUser.uid!);

      _db.fetchUserStream(_currentUser.uid).listen((data) {
        _users = data.docs.map((e) => UserModel.fromMap(e.data())).toList();
        _filteredUsers = users;
        log("#################Filtered Users: $_filteredUsers");
        notifyListeners();
      });

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

        log("_chatRooms: //////////////////////////////${_chatRooms}");
        notifyListeners();
      });

      // it is return by getChatRooms()

      //       {
      //   "lastMessage": {
      //     "senderId": "3m6EEfB4lLZJTuRBmrK7kUbQg5U2",
      //     "content": "hey you also fuck off",
      //     "timestamp": 1740639201493
      //   },
      //   "unreadCounters": {
      //     "f3D905EoU0QisLZDRg9vwmmy0zC2": 0,
      //     "3m6EEfB4lLZJTuRBmrK7kUbQg5U2": 0
      //   },
      //   "users": [
      //     "3m6EEfB4lLZJTuRBmrK7kUbQg5U2",
      //     "f3D905EoU0QisLZDRg9vwmmy0zC2"
      //   ]
      // }

      // if (res != null) {
      //   _users = res.map((e) => UserModel.fromMap(e)).toList();
      //   _filteredUsers = _users;
      //   notifyListeners();
      // }
      setState(ViewState.idle);
    } catch (e) {
      setState(ViewState.idle);
      log("Error Fetching Users: $e");
    }
  }

  List<Map<String, dynamic>> getMergedChatList() {
    // Step 1: Create a Map from chatRooms for quick lookup
    final Map<String, dynamic> chatRoomMap = {
      for (var chat in chatRooms)
        chat["users"].firstWhere((uid) => uid != _currentUser.uid): chat,
    };

    // Step 2: Separate users into two lists
    List<Map<String, dynamic>> usersWithChats = [];
    List<Map<String, dynamic>> usersWithoutChats = [];

    for (var user in filteredUsers) {
      if (chatRoomMap.containsKey(user.uid)) {
        // If user has an active chat
        final chatRoom = chatRoomMap[user.uid];
        usersWithChats.add({
          "user": user,
          "lastMessage": chatRoom["lastMessage"]?["content"] ?? "",
          "timestamp": chatRoom["lastMessage"]?["timestamp"] ?? 0,
          "unreadCount": chatRoom["unreadCounters"]?[_currentUser.uid] ?? 0,
        });
      } else {
        // If user has no active chat
        usersWithoutChats.add({
          "user": user,
          "lastMessage": "",
          "timestamp": 0,
          "unreadCount": 0,
        });
      }
    }

    // Step 3: Sort users with chats by latest message timestamp
    usersWithChats.sort((a, b) => b["timestamp"].compareTo(a["timestamp"]));

    // Step 4: Merge both lists and return
    return [...usersWithChats, ...usersWithoutChats];
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
