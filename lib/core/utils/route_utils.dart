import 'package:chat_app/core/constants/strings.dart';
import 'package:chat_app/core/models/user_model.dart';
import 'package:chat_app/ui/screens/auth/login/login_screen.dart';
import 'package:chat_app/ui/screens/auth/signup/signup_screen.dart';
import 'package:chat_app/ui/screens/bottom_navigation/chats_list/chats_room/chat_screen.dart';
import 'package:chat_app/ui/screens/bottom_navigation/profile/profile_screen.dart';
import 'package:chat_app/ui/screens/home/home_screen.dart';
import 'package:chat_app/ui/screens/splash/splash_screen.dart';
import 'package:chat_app/ui/screens/wrapper/wrapper.dart';
import 'package:flutter/material.dart';

class RouteUtils {
  static Route<dynamic>? onGenerateRoute(RouteSettings setting) {
    final args = setting.arguments;
    switch (setting.name) {
      case splash:
        return MaterialPageRoute(builder: (context) => SplashScreen());

      case login:
        return MaterialPageRoute(builder: (context) => LoginScreen());

      case signup:
        return MaterialPageRoute(builder: (context) => SignupScreen());

      case wrapper:
        return MaterialPageRoute(builder: (context) => Wrapper());

      case home:
        return MaterialPageRoute(builder: (context) => HomeScreen());

      case profile:
        return MaterialPageRoute(builder: (context) => ProfileScreen());

      case chatScreen:
        return MaterialPageRoute(
          builder: (context) => ChatScreen(receiver: args as UserModel),
        );

      default:
        return MaterialPageRoute(
          builder:
              (context) =>
                  Scaffold(body: Center(child: Text("No Route Found"))),
        );
    }
  }
}
