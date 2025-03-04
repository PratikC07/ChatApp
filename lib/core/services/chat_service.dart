import 'dart:developer';

import 'package:chat_app/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final _fire = FirebaseFirestore.instance;

  saveMessage(Map<String, dynamic> message, String chatRoomId) async {
    try {
      log("ChatRoom Id in the saveMessage: $chatRoomId -inside saveMessage");
      await _fire
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(message);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createChatRoomIfNotExists(
    UserModel currentUser,
    UserModel receiver,
  ) async {
    String currentUserId = currentUser.uid;
    String receiverId = receiver.uid;

    String chatRoomId =
        (currentUserId.compareTo(receiverId) > 0)
            ? "${currentUserId}_$receiverId"
            : "${receiverId}_$currentUserId";

    final chatRoomRef = _fire.collection("chatRooms").doc(chatRoomId);
    final chatRoomSnapshot = await chatRoomRef.get();

    if (!chatRoomSnapshot.exists) {
      log("⚠️ Chat room does NOT exist! Creating it now...");
      await chatRoomRef.set({
        "users": {
          currentUserId: currentUser.toMap(), // ✅ Convert to Map
          receiverId: receiver.toMap(),
        }, // ✅ Convert to Map], // ✅ Store only user UIDs
        "createdAt": FieldValue.serverTimestamp(),
        "lastMessage": null,
        "unreadCounters": {currentUserId: 0, receiverId: 0},
      });
    }
    log("ChatRoom is created using reateChatRoomIfNotExists Method");
  }

  Future<void> updateLastMessage(
    UserModel currentUser,
    UserModel receiverUser,
    String message,
    int timestamp,
  ) async {
    try {
      // Generate chat room ID based on sorted UIDs
      String currentUserId = currentUser.uid;
      String receiverUserId = receiverUser.uid;
      String chatRoomId =
          (currentUserId.compareTo(receiverUserId) > 0)
              ? "${currentUserId}_$receiverUserId"
              : "${currentUserId}_$receiverUserId";

      log(
        "Chat Room ID: $chatRoomId - inside updateLastMessage",
      ); // 🔥 Debugging Line

      final chatRoomRef = _fire.collection("chatRooms").doc(chatRoomId);

      // Check if the chat room document exists
      final chatRoomSnapshot = await chatRoomRef.get();

      if (!chatRoomSnapshot.exists) {
        log("⚠️ Chat room does NOT exist!"); // 🔥 Debugging Line
      } else {
        log("✅ Chat room exists, proceeding to update..."); // 🔥 Debugging Line
      }

      // Update last message inside the chat room document
      await _fire.collection("chatRooms").doc(chatRoomId).set({
        "users": {
          currentUser.uid: currentUser.toMap(), // ✅ Convert to Map
          receiverUser.uid: receiverUser.toMap(), // ✅ Convert to Map
        },
        "lastMessage": {
          "content": message,
          "timestamp": timestamp,
          "senderId": currentUserId,
        },
        "unreadCounters": {
          currentUserId: 0, // Initialize unread count for sender
          receiverUserId: FieldValue.increment(
            1,
          ), // Increment unread count for receiver
        },
      }, SetOptions(merge: true));

      log("✅ Last message updated successfully!"); // 🔥 Debugging Line
    } catch (e) {
      log("❌ Error updating last message: $e"); // 🔥 Debugging Line
      rethrow;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(String chatRoomId) {
    return _fire
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> resetUnreadCount(String chatRoomId, String userId) async {
    try {
      // Handling the case of New User

      // final chatRoomRef = _fire.collection("chatRooms").doc(chatRoomId);

      // // Check if the chat room document exists
      // final chatRoomSnapshot = await chatRoomRef.get();

      // if (!chatRoomSnapshot.exists) {
      //   log("⚠️ Chat room does NOT exist!"); // 🔥 Debugging Line
      // } else {
      //   await _fire.collection("chatRooms").doc(chatRoomId).update({
      //     "unreadCounters.$userId":
      //         0, // ✅ Correctly updating inside unreadCounters map
      //   });
      //   log("✅ Unread count reset for $userId in chatRoom: $chatRoomId");
      // }

      await _fire.collection("chatRooms").doc(chatRoomId).update({
        "unreadCounters.$userId":
            0, // ✅ Correctly updating inside unreadCounters map
      });
      log("✅ Unread count reset for $userId in chatRoom: $chatRoomId");
    } catch (e) {
      log("❌ Error resetting unread count: $e");
    }
  }
}
