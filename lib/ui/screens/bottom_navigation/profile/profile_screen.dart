import 'dart:developer';

import 'package:chat_app/core/constants/strings.dart';
import 'package:chat_app/core/models/user_model.dart';
import 'package:chat_app/core/services/auth_service.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:chat_app/core/services/storage_service.dart';
import 'package:chat_app/ui/screens/bottom_navigation/profile/profile_viewmodel.dart';
import 'package:chat_app/ui/screens/other/user_provider.dart';
import 'package:chat_app/ui/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileViewmodel model;
  late TextEditingController nameController;
  late TextEditingController emailController;
  bool isEditing = false; // Track edit mode

  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = context.read<UserProvider>().user;
    model = ProfileViewmodel(SupabaseStorageService(), DatabaseService());
    model.setUserData(
      currentUser!.name,
      currentUser!.email,
      currentUser!.imageUrl,
    );
    // Initialize controllers with existing user data
    nameController = TextEditingController(text: currentUser!.name);
    emailController = TextEditingController(text: currentUser!.email);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  showUserProvider(UserModel currentUser2) {
    log("UserProvider : ${currentUser2.imageUrl}");
    log("DisplayUser : ${model.imageUrl}");
  }

  Widget UserImageShow(ProfileViewmodel model) {
    // return model.imageUrl == "null"
    //     ? CircleAvatar(radius: 60.r, child: const Icon(Icons.camera_alt))
    //     : model.image != null
    //     ? CircleAvatar(radius: 60.r, backgroundImage: FileImage(model.image!))
    //     : CircleAvatar(
    //       radius: 60.r,
    //       backgroundImage: NetworkImage(model.imageUrl),
    //     );
    return Stack(
      alignment: Alignment.bottomRight, // Align edit icon to bottom-right
      children: [
        CircleAvatar(
          radius: 60.r,
          backgroundImage:
              model.imageUrl == "null"
                  ? null
                  : model.image != null
                  ? FileImage(model.image!)
                  : NetworkImage(model.imageUrl),
          child:
              model.imageUrl == "null"
                  ? const Icon(
                    Icons.camera_alt,
                    size: 40,
                  ) // Show icon when no image
                  : null,
        ),
        Positioned(
          bottom: 0,
          right: 6,
          child: GestureDetector(
            onTap: () async {
              await model.pickImage();
              if (model.image != null) {
                await model.updateProfileImage(currentUser!.uid, context);
              } else {
                log("Picture is selected but it is not updated");
              }
            },

            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey[350],
              child: Icon(
                Icons.camera_alt_outlined,
                size: 20,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser2 = context.watch<UserProvider>().user;
    navigateToDisplayImage(ProfileViewmodel model) {
      Navigator.pushNamed(
        context,
        displayImage,
        arguments: model,
      ); // Navigate to display screen
    }

    showUserProvider(currentUser2!);
    return ChangeNotifierProvider(
      create: (context) => model,

      child: Consumer<ProfileViewmodel>(
        builder: (context, model, _) {
          return Scaffold(
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.sw * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () => navigateToDisplayImage(model),
                    child: UserImageShow(model),
                  ),

                  20.verticalSpace,

                  //update User Name
                  Row(
                    children: [
                      Expanded(
                        child:
                            isEditing
                                ? TextField(
                                  controller: nameController,
                                  decoration: InputDecoration(
                                    labelText: "Name",
                                  ),
                                )
                                : Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Icon(Icons.person_outlined, size: 34),
                                    15.horizontalSpace,
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Name",
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          model.name,
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                      ),
                      IconButton(
                        icon: Icon(isEditing ? Icons.check : Icons.edit),
                        onPressed: () {
                          if (isEditing) {
                            // Save new email
                            model.setUserData(
                              nameController.text,
                              emailController.text,
                              model.imageUrl,
                            );
                            model.updateProfileImage(currentUser!.uid, context);
                          }
                          setState(() {
                            isEditing = !isEditing; // Toggle edit mode
                          });
                        },
                      ),
                    ],
                  ),

                  10.verticalSpace,
                  // Email Field with Edit Icon
                  Row(
                    children: [
                      Expanded(
                        child:
                            isEditing
                                ? TextField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    labelText: "Email",
                                  ),
                                )
                                : Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Icon(Icons.email_outlined, size: 34),
                                    15.horizontalSpace,
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Email",
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          model.email,
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                      ),
                      IconButton(
                        icon: Icon(isEditing ? Icons.check : Icons.edit),
                        onPressed: () {
                          if (isEditing) {
                            // Save new email
                            model.setUserData(
                              nameController.text,
                              emailController.text,
                              model.imageUrl,
                            );
                            model.updateProfileImage(currentUser!.uid, context);
                          }
                          setState(() {
                            isEditing = !isEditing; // Toggle edit mode
                          });
                        },
                      ),
                    ],
                  ),

                  50.verticalSpace,
                  CustomButton(
                    text: "Logout",
                    onPressed: () {
                      context.read<UserProvider>().clearUser();
                      AuthService().logout();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
