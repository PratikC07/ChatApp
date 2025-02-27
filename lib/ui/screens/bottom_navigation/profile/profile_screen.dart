import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/core/services/auth_service.dart';
import 'package:chat_app/ui/screens/other/user_provider.dart';
import 'package:chat_app/ui/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<UserProvider>().user;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.sw * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text("UserName: ${currentUser!.name}", style: h),
                10.verticalSpace,
                Text("Email: ${currentUser.email}", style: h),
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
  }
}
