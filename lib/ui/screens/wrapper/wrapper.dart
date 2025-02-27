import 'dart:developer';

import 'package:chat_app/ui/screens/auth/login/login_screen.dart';
import 'package:chat_app/ui/screens/bottom_navigation/bottom_navigation_screen.dart';
import 'package:chat_app/ui/screens/other/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  // Future<void> _loadUser(BuildContext context, String uid) async {
  //   await context.read<UserProvider>().loadUser(uid);
  // }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        log("Auth state changed: User is ${user?.uid}");

        // if (user == null) {
        //   return const LoginScreen();
        // } else {
        //   // context.read<UserProvider>().loadUser(user.uid);
        //   // return BottomNavigationScreen();

        //   return FutureBuilder(
        //     future: _loadUser(context, user.uid),
        //     builder: (context, snapshot) {
        //       if (snapshot.connectionState == ConnectionState.waiting) {
        //         return Scaffold(
        //           body: const Center(child: CircularProgressIndicator()),
        //         );
        //       }
        //       return BottomNavigationScreen();
        //     },
        //   );
        // }
        if (user == null) {
          return const LoginScreen();
        }

        final userProvider = context.watch<UserProvider>();

        if (userProvider.user == null || user.uid != userProvider.user!.uid) {
          log(
            "[Wrapper] User data is null, reloading...- calling the loadUser func",
          );
          userProvider.loadUser(user.uid); // Ensure it retries

          log('showing loading screen until currentUser is not set');
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        log(
          "here it is confirmed that the currentUser is set, building bottomNavigation Screen",
        );

        return const BottomNavigationScreen();
      },
    );
  }
}
