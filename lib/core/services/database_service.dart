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

  Future<Map<String, dynamic>?> fetchUser(String userId) async {
    try {
      final res = await _fire.collection('users').doc(userId).get();
      if (!res.exists || res.data() == null) {
        throw Exception("User not found");
      }
      return res.data();
    } catch (e) {
      log("Error Occured while fetching User Info");
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
          "users.$userId",
          isNull: false,
        ) // ✅ Check if userId exists in the users map
        .snapshots();
  }

  ////////////////////////////
  Future<void> updateUserInfo(
    String userId,
    String name,
    String email,
    String profilePicUrl,
  ) async {
    try {
      await _fire.collection('users').doc(userId).update({
        'name': name,
        'email': email,
        'imageUrl': profilePicUrl,
      });
    } catch (e) {
      log("Error while updating user info: $e");
      rethrow;
    }
  }
}
