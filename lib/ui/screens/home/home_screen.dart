import 'package:chat_app/core/extension/widget_extension.dart';
import 'package:chat_app/core/services/auth_service.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:chat_app/ui/screens/home/home_viewmodel.dart';
import 'package:chat_app/ui/screens/other/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    logout() {
      AuthService().logout();
      context.showSnackbar("LogOut from the Account");
    }

    return ChangeNotifierProvider(
      create: (context) => HomeViewmodel(DatabaseService()),
      child: Consumer<HomeViewmodel>(
        builder: (context, model, _) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Consumer<UserProvider>(
                    builder: (context, userProvider, _) {
                      return Center(
                        child:
                            userProvider.user == null
                                ? CircularProgressIndicator()
                                : Text(userProvider.user.toString()),
                      );
                    },
                  ), // show data
                  Center(
                    child: TextButton(onPressed: logout, child: Text('Logout')),
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
