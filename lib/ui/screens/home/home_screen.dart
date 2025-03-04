import 'dart:developer';
import 'package:chat_app/core/services/chat_service.dart';
import 'package:intl/intl.dart';
import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/strings.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/core/enums/enums.dart';
import 'package:chat_app/core/models/user_model.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:chat_app/ui/screens/bottom_navigation/chats_list/chats_list_viewmodel.dart';
import 'package:chat_app/ui/screens/other/user_provider.dart';

import 'package:chat_app/ui/widgets/textfield_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    onTap(UserModel currentUser, UserModel otherUser) {
      final chatRoomId =
          (currentUser.uid.compareTo(otherUser.uid) > 0)
              ? "${currentUser.uid}_${otherUser.uid}"
              : "${otherUser.uid}_${currentUser.uid}";

      log("chatRoomId: $chatRoomId in onTap Method");

      ChatService().resetUnreadCount(chatRoomId, currentUser.uid);

      Navigator.pushNamed(context, chatScreen, arguments: otherUser);
    }

    final currentUser = context.read<UserProvider>().user;
    return ChangeNotifierProvider(
      create: (context) => ChatsListViewmodel(DatabaseService(), currentUser!),
      child: Consumer<ChatsListViewmodel>(
        builder: (context, model, _) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 1.sw * 0.05,
              vertical: 10.h,
            ),
            child: Column(
              children: [
                30.verticalSpace,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Users", style: h),
                ),
                20.verticalSpace,
                TextfieldWidget(
                  hintText: "Search Here",
                  isSearch: true,
                  onChanged: model.search,
                ),
                5.verticalSpace,
                model.state == ViewState.loading
                    ? const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : model.users.isEmpty
                    ? const Expanded(child: Center(child: Text("No Users yet")))
                    : Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        itemCount: model.filteredUsers.length,
                        physics: const BouncingScrollPhysics(),
                        separatorBuilder: (context, index) => 8.verticalSpace,
                        itemBuilder: (context, index) {
                          final user = model.filteredUsers[index];

                          return ChatTile(
                            user: user,

                            onTap: () => onTap(currentUser!, user),
                          );
                        },
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ChatTile extends StatelessWidget {
  ChatTile({
    super.key,
    this.onTap,
    required this.user,
    // required this.lastMessage,
    // required this.timestamp,
    // required this.unreadCount,
  });

  final UserModel user;
  // final String lastMessage;
  // final int timestamp;
  // final int unreadCount;
  void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    // log("user : ${user.name}");
    // log("lastMessage : $lastMessage");
    // log("timestamp : $timestamp");
    // log("unreadCount : $unreadCount");

    log("///////////////////////////////////////");

    return Container(
      decoration: BoxDecoration(
        color: grey.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        onTap: onTap,
        // tileColor: grey.withOpacity(0.12),
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8),
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(12.r),
        // ),
        leading:
            user.imageUrl == "null"
                ? CircleAvatar(
                  backgroundColor: grey.withOpacity(0.5),
                  radius: 25,
                  child: Text(user.name[0].toUpperCase(), style: h),
                )
                : ClipOval(
                  child: Image.network(
                    user.imageUrl,
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
        title: Text(user.name, style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

String getTimeAgo(int timestamp) {
  DateTime sentTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  DateTime now = DateTime.now();
  Duration difference = now.difference(sentTime);

  if (difference.inMinutes < 1) {
    return "Just now"; // Instead of seconds
  } else if (difference.inMinutes < 60) {
    return "${difference.inMinutes} min ago";
  } else if (difference.inHours < 24) {
    return "${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago";
  } else if (difference.inDays == 1) {
    return "Yesterday";
  } else if (difference.inDays < 7) {
    return "${difference.inDays} days ago";
  } else {
    return DateFormat('MMM d, yyyy').format(sentTime); // Example: Mar 12, 2025
  }
}
