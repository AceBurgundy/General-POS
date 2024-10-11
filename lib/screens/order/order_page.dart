import 'package:general_pos/constants.dart';
import 'package:general_pos/screens/main_page.dart';
import 'package:general_pos/screens/page.dart';
import 'package:general_pos/utilities/providers/total_amount.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../../models/cart.dart';
import '../../models/product.dart';
import '../../utilities/providers/cart_item_counter.dart';
import 'widgets/grid_cart_item.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  OrderPageState createState() => OrderPageState();
}

class OrderPageState extends State<OrderPage> {
  List<Product> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    setState(() {
      isLoading = true;
    });

    loadProducts();
  }

  void _removeItem(String id) async {
    List<Product> updatedCart = await Cart.removeProduct(id: id);

    if (mounted) {
      Provider.of<CartItemCounter>(context, listen: false)
          .updateCartItemCount();
      Provider.of<TotalAmount>(context, listen: false).displayTotalAmount();
    }

    setState(() {
      products = updatedCart;
    });
  }

  void loadProducts({String? searchName}) async {
    var queriedProducts = await Cart.all(whereName: searchName);

    setState(() {
      products = queriedProducts;
      isLoading = false;
    });
  }

  void pay() async {
    bool payed = await Cart.pay(context);

    if (!payed) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pay cart')),
        );
      }
    }

    List<Product> clearedCart = await Cart.clear();

    if (mounted) {
      Provider.of<TotalAmount>(context, listen: false).displayTotalAmount();
      Provider.of<CartItemCounter>(context, listen: false).updateCartItemCount();
    }

    setState(() {
      products = clearedCart;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart paid successfully')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Section<Product>(
      dataList: products,
      hideAppBarActions: true,
      isLoading: isLoading,
      showChildAsList: true,
      dataListEmptyButtonOnTapDestination: const MainPage(pageIndex: 0),
      dataListEmptyText: 'Choose New Product',
      itemBuilder: (context, product) =>
          GridCartCardWidget(product: product, onDeletePressed: _removeItem),
      floatingActionButton: products.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => pay(),
              label: Consumer<TotalAmount>(builder: (context, holder, c) {
                return Text(
                  'Pay | ${asCurrency(holder.totalAmount)}',
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                );
              }),
              icon: const Icon(Icons.monetization_on),
            ),
    );
  }
}
