// ignore_for_file: file_names

import 'package:flutter/material.dart';

class LoginNavigationProvider extends ChangeNotifier {
  final List<bool> _selectedpage = [
    true,
    false,
    false,
    false,
  ];

  int get selectedpage => _select;

  List<bool> get selected => _selectedpage;

  int _select = 0;

  void select(int n) {
    for (int i = 0; i < 2; i++) {
      if (i != n) {
        _selectedpage[i] = false;
        _select = n;
      } else {
        _selectedpage[i] = true;
      }
      notifyListeners();
    }
  }

  reset() {
    _select = 0;
    _selectedpage[0] = true;
    notifyListeners();
  }
}
