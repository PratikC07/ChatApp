import 'dart:developer';

import 'package:chat_app/core/constants/strings.dart';
import 'package:chat_app/ui/screens/bottom_navigation/bottom_navigation_viewmodel.dart';
import 'package:chat_app/ui/screens/bottom_navigation/chats_list/chats_list_screen.dart';
import 'package:chat_app/ui/screens/bottom_navigation/profile/profile_screen.dart';
import 'package:chat_app/ui/screens/home/home_screen.dart';
import 'package:chat_app/ui/screens/other/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class BottomNavigationScreen extends StatelessWidget {
  const BottomNavigationScreen({super.key});

  static final List<Widget> _items = [
    Center(child: HomeScreen()),
    Center(child: ChatsListScreen()),
    Center(child: ProfileScreen()),
  ];
  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).user;
    log("Current User: $currentUser");

    List<BottomNavigationBarItem> items = [
      BottomNavigationBarItem(
        icon: BottomNavButton(iconPath: homeIcon),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: BottomNavButton(iconPath: chatsIcon),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: BottomNavButton(iconPath: profileIcon),
        label: '',
      ),
    ];

    return ChangeNotifierProvider(
      create: (context) => BottomNavigationViewmodel(),
      child: Consumer<BottomNavigationViewmodel>(
        builder: (context, model, child) {
          return currentUser == null
              ? const Center(child: CircularProgressIndicator())
              : Scaffold(
                // backgroundColor: Colors.grey,
                body: _items[model.current],
                bottomNavigationBar: CustomNavBar(items: items),
              );
        },
      ),
    );
  }
}

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({super.key, this.onTap, required this.items});

  final void Function(int)? onTap;
  final List<BottomNavigationBarItem> items;

  @override
  Widget build(BuildContext context) {
    onTap(int index) {
      context.read<BottomNavigationViewmodel>().setIndex(index);
    }

    const borderRadius = BorderRadius.only(
      topLeft: Radius.circular(30.0),
      topRight: Radius.circular(30.0),
    );

    return Container(
      decoration: const BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 10),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        child: BottomNavigationBar(onTap: onTap, items: items),
      ),
    );
  }
}

class BottomNavButton extends StatelessWidget {
  const BottomNavButton({super.key, required this.iconPath});
  final String iconPath;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Image.asset(iconPath, width: 35, height: 35),
    );
  }
}
