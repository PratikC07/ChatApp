import 'dart:developer';

import 'package:chat_app/core/models/user_model.dart';

import 'package:chat_app/ui/screens/bottom_navigation/profile/profile_viewmodel.dart';
import 'package:chat_app/ui/screens/other/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class DisplayImageScreen extends StatefulWidget {
  final ProfileViewmodel model;
  const DisplayImageScreen({super.key, required this.model});

  @override
  _DisplayImageScreenState createState() => _DisplayImageScreenState();
}

class _DisplayImageScreenState extends State<DisplayImageScreen> {
  late ProfileViewmodel model = widget.model;
  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = context.read<UserProvider>().user;
  }

  showUserProvider(UserModel currentUser2) {
    log("UserProvider : ${currentUser2.imageUrl}");
    log("DisplayUser : ${model.imageUrl}");
  }

  @override
  Widget build(BuildContext context) {
    final currentUser2 = context.watch<UserProvider>().user;
    onIconPressed(ProfileViewmodel model) async {
      await model.pickImage();
      if (model.image != null) {
        await model.updateProfileImage(currentUser!.uid, context);
      } else {
        log("Picture is selected but it is not updated");
      }
    }

    showUserProvider(currentUser2!);

    return ChangeNotifierProvider.value(
      value: model,

      child: Consumer<ProfileViewmodel>(
        builder: (context, model, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Display Image Screen'),
              actions: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => onIconPressed(model),
                ),
              ],
            ),
            body:
                model.imageUrl == "null"
                    ? Container(
                      height: 400.h,
                      width: 1.sw,
                      margin: EdgeInsets.symmetric(vertical: 60.h),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: const Icon(Icons.camera_alt),
                      ),
                    )
                    : model.image != null
                    ? Container(
                      height: 400.h,
                      width: 1.sw,
                      margin: EdgeInsets.symmetric(vertical: 60.h),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.file(model.image!, fit: BoxFit.cover),
                      ),
                    )
                    : Container(
                      height: 400.h,
                      width: 1.sw,
                      margin: EdgeInsets.symmetric(vertical: 60.h),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(model.imageUrl, fit: BoxFit.cover),
                      ),
                    ),
          );
        },
      ),
    );
  }
}
