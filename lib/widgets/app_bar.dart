import 'package:flutter/material.dart';
import 'package:general_pos/app_name.dart';
import 'package:general_pos/screens/order/order_page.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../utilities/providers/cart_item_counter.dart';
import '../utilities/string_constant.dart';

class POSAppBar extends StatefulWidget implements PreferredSizeWidget {
  final PreferredSizeWidget? bottom;
  final bool hideLeading;
  final bool hideActions;

  const POSAppBar({super.key, this.bottom, this.hideLeading = true, this.hideActions = false});

  @override
  State<POSAppBar> createState() => _POSAppBarState();

  @override
  Size get preferredSize => bottom == null
      ? Size(56, AppBar().preferredSize.height)
      : Size(56, 80 + AppBar().preferredSize.height);
}

class _POSAppBarState extends State<POSAppBar> with AutomaticKeepAliveClientMixin<POSAppBar> {
  String appName = '';

  @override
  void initState() {
    super.initState();
    _loadAppName();
  }

  Future<void> _loadAppName() async {
    String name = await AppName.get() ?? 'General POS';

    setState(() {
      appName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);  // Required to inform Flutter that this widget wants to keep its state alive

    Icon counterBox = Icon(
      Icons.brightness_1,
      size: 20.0,
      color: Theme.of(context).primaryColor,
    );

    Positioned counterBoxCounter = Positioned(
      top: 3,
      right: 7,
      child: Center(
        child: Consumer<CartItemCounter>(
          builder: (context, counter, c) {
            return Text(
              counter.count.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            );
          },
        ),
      ),
    );

    Stack cart = Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OrderPage()),
          ),
        ),
        Positioned(
          child: Stack(children: [counterBox, counterBoxCounter]),
        )
      ],
    );

    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      title: Text(appName, style: const TextStyle(fontFamily: "Poppins")),
      automaticallyImplyLeading: !widget.hideLeading,
      centerTitle: true,
      actions: [!widget.hideActions ? cart : const SizedBox.shrink()],
    );
  }

  // This ensures the state is kept alive keeping the app name from split second blinking
  @override
  bool get wantKeepAlive => true;
}
