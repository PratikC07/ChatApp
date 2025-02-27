import 'package:flutter/material.dart';

class BottomNavigationViewmodel extends ChangeNotifier {
  int _currentIndex = 1;

  int get current => _currentIndex;

  setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }
}
