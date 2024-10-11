import 'package:flutter/cupertino.dart';
import 'package:general_pos/models/cart.dart';

class CartItemCounter extends ChangeNotifier {
  int cartListItemCounter = 0;

  CartItemCounter() {
    _initializeCartCount();
  }

  int get count => cartListItemCounter;

  Future<void> _initializeCartCount() async {
    cartListItemCounter = await Cart.count();
    notifyListeners();
  }

  Future<void> updateCartItemCount() async {
    cartListItemCounter = await Cart.count();
    await Future.delayed(const Duration(milliseconds: 100), () => notifyListeners());
  }
}
