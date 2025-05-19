import 'package:flutter/material.dart';

class BalanceProvider with ChangeNotifier {
  double _balance = 0.0;

  double get balance => _balance;

  void updateBalance(double newBalance) {
    _balance = newBalance;
    notifyListeners();
  }
}
