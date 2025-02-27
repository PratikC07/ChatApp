import 'dart:developer';

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

  Future<void> updateLastMessage(
    String currentUid,
    String receiverUid,
    String message,
    int timestamp,
  ) async {
    try {
      // Generate chat room ID based on sorted UIDs
      String chatRoomId =
          (currentUid.compareTo(receiverUid) > 0)
              ? "${currentUid}_${receiverUid}"
              : "${receiverUid}_${currentUid}";

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
        "users": [currentUid, receiverUid],
        "lastMessage": {
          "content": message,
          "timestamp": timestamp,
          "senderId": currentUid,
        },
        "unreadCounters": {
          currentUid: 0, // Initialize unread count for sender
          receiverUid: FieldValue.increment(
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
