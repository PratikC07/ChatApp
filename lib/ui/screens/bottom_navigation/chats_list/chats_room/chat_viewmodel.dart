import 'dart:async';
import 'dart:developer';

import 'package:chat_app/core/models/message_model.dart';
import 'package:chat_app/core/models/user_model.dart';
import 'package:chat_app/core/other/base_viewmodel.dart';
import 'package:chat_app/core/services/chat_service.dart';
import 'package:flutter/material.dart';

class ChatViewmodel extends BaseViewmodel {
  final ChatService _chatService;
  final UserModel _currentUser;
  final UserModel _receiver;
  StreamSubscription? _subscription;

  ChatViewmodel(this._chatService, this._currentUser, this._receiver) {
    getChatRoomId();

    _subscription = _chatService.getMessages(chatRoomId).listen((messages) {
      _messages =
          messages.docs.map((e) => MessageModel.fromMap(e.data())).toList();
      notifyListeners();
    });
  }

  String chatRoomId = "";

  final _messageController = TextEditingController();
  TextEditingController get controller => _messageController;

  List<MessageModel> _messages = [];
  List<MessageModel> get messages => _messages;

  getChatRoomId() {
    if (_currentUser.uid.compareTo(_receiver.uid) > 0) {
      chatRoomId = "${_currentUser.uid}_${_receiver.uid}";
    } else {
      chatRoomId = "${_receiver.uid}_${_currentUser.uid}";
    }
  }

  saveMessage() async {
    log("Send Message");
    try {
      if (_messageController.text.isEmpty) {
        throw Exception("Please enter some text");
      }
      final now = DateTime.now();
      final message = MessageModel(
        id: now.millisecondsSinceEpoch.toString(),
        content: _messageController.text,
        senderId: _currentUser.uid,
        receiverId: _receiver.uid,
        timestamp: now,
      );
      // await _chatService.saveMessage(message.toMap(), chatRoomId);
      // _messageController.clear();

      // 1️⃣ Ensure chat room exists before adding the message
      await _chatService.createChatRoomIfNotExists(_currentUser, _receiver);

      // 2️⃣ Save message in Firestore
      await _chatService.saveMessage(message.toMap(), chatRoomId);

      // 3️⃣ Update last message and unread counter
      log("updating the last message");
      await _chatService.updateLastMessage(
        _currentUser,
        _receiver,
        message.content!,
        now.millisecondsSinceEpoch,
      );

      // 4️⃣ Clear input field after sending
      _messageController.clear();
    } catch (e) {
      log("❌ Error sending message: $e");
      rethrow;
    }
  }

  @override
  void dispose() {
    super.dispose();

    _subscription?.cancel();
  }
}
