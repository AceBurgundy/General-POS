import 'package:flutter/cupertino.dart';

import '../../models/cart.dart';

class TotalAmount extends ChangeNotifier {
  double _totalAmount = 0.0;
  double get totalAmount => _totalAmount;

  TotalAmount() {
    _initializeTotal();
  }

  _initializeTotal() async {
    _totalAmount = await Cart.total();
  }

  displayTotalAmount() async {
    _initializeTotal();

    await Future.delayed(const Duration(milliseconds: 100), () {
      notifyListeners();
    });
  }
}