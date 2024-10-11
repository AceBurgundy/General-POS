import 'package:general_pos/models/product.dart';
import 'package:general_pos/screens/main_page.dart';
import 'package:general_pos/screens/page.dart';
import 'package:general_pos/screens/records/records.dart';
import 'package:general_pos/screens/home/widgets/grid_shop_item.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
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

  void loadProducts({ String? searchName }) async {
    var queriedProducts = await Products.all(whereName: searchName);

    setState(() {
      products = queriedProducts;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Section<Product>(
      dataList: products,
      isLoading: isLoading,
      onSearchChanged: (searchValue) => loadProducts(searchName: searchValue),
      dataListEmptyButtonOnTapDestination: const MainPage(pageIndex: 2),
      dataListEmptyText: 'Add New Product',
      itemBuilder: (context, product) => GridShopCardWidget(product: product),
    );
  }
}