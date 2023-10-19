import 'package:flutter/material.dart';

class BottomNavProvider extends ChangeNotifier {
  final List<bool> _selectedtab = [
    true,
    false,
    false,
    false,
    false,
    false,
  ];

  int get selectetab => _select;

  List<bool> get selected => _selectedtab;

  int _select = 0;

  void select(int n) {
    for (int i = 0; i < 5; i++) {
      if (i != n) {
        _selectedtab[i] = false;
        _select = n;
      } else {
        _selectedtab[i] = true;
      }
      notifyListeners();
    }
  }
}
