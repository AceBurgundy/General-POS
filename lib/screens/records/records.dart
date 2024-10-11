import 'package:flutter/material.dart';
import 'package:general_pos/screens/page.dart';
import 'package:general_pos/screens/records/widgets/add_record_form.dart';
import '../../models/product.dart';
import 'widgets/grid_record_item.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  RecordsState createState() => RecordsState();
}

class RecordsState extends State<RecordPage> {
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
    FloatingActionButton addProductDialog = FloatingActionButton.extended(
      onPressed: () {
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: '',
          barrierColor: Colors.black54,
          transitionDuration: const Duration(milliseconds: 200),
          pageBuilder: (context, animation1, animation2) {
            return Align(
              alignment: Alignment.center, // Center alignment
              child: AddRecordForm(refreshRecord: loadProducts),
            );
          },
          transitionBuilder: (context, enterAnimation, exitAnimation, child) {
            const begin = Offset(0.0, 0.07);
            const end = Offset(0.0, 0.04);

            var tween = Tween<Offset>(begin: begin, end: end);
            var offsetAnimation = enterAnimation.drive(tween);
            var opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(enterAnimation);

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: opacityAnimation,
                child: child,
              ),
            );
          },
        );
      },
      label: const Text('Add Item'),
      icon: const Icon(Icons.add),
    );

    return Section<Product>(
      dataList: products,
      isLoading: isLoading,
      onSearchChanged: (searchValue) => loadProducts(searchName: searchValue),
      dataListEmptyText: 'No Records Yet',
      itemBuilder: (context, product) => GridRecordCardWidget(product: product, refreshRecord: loadProducts),
      floatingActionButton: addProductDialog,
    );
  }
}
