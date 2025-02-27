import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final _fire = FirebaseFirestore.instance;

  Future<void> saveUser(Map<String, dynamic> userData) async {
    try {
      await _fire.collection('users').doc(userData['uid']).set(userData);
      log("User data saved successfully - in the database service");
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> loadUser(String uid) async {
    try {
      log("inside database service - load user");
      final res = await _fire.collection("users").doc(uid).get();
      if (res.data() != null) {
        log('returning user data - db load user');
        return res.data(); // returns a map
      }
      log("returning null");
    } catch (e) {
      rethrow;
    }
    return null; // returns null if user data is not found
  }

  Future<List<Map<String, dynamic>>> fetchUsers(String currentUserId) async {
    try {
      final res =
          await _fire
              .collection("users")
              .where("uid", isNotEqualTo: currentUserId)
              .get();
      return res.docs.map((e) => e.data()).toList();
    } catch (e) {
      rethrow;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchUserStream(
    String currentUserId,
  ) =>
      _fire
          .collection("users")
          .where("uid", isNotEqualTo: currentUserId)
          .snapshots();

  /////////////////////////////
  Stream<QuerySnapshot<Map<String, dynamic>>> getChatRooms(String userId) {
    return _fire
        .collection("chatRooms")
        .where(
          "users",
          arrayContains: userId,
        ) // Fetch rooms where the user exists
        .snapshots();
  }
}
