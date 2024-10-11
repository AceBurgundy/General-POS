import 'package:general_pos/widgets/app_bar.dart';
import 'package:general_pos/widgets/page_search_input.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';

class Section<T> extends StatefulWidget {
  final List<T> dataList;
  final bool isLoading;
  final bool hideAppBarActions;
  final bool showChildAsList;
  final Function(String)? onSearchChanged;
  final Widget? dataListEmptyButtonOnTapDestination;
  final String dataListEmptyText;
  final bool textOnlyIfDataListIsEmpty;
  final Widget Function(BuildContext, Product) itemBuilder;
  final FloatingActionButton? floatingActionButton;

  const Section({
    super.key,
    required this.dataList,
    required this.isLoading,
    this.showChildAsList = false,
    this.hideAppBarActions = false,
    this.onSearchChanged,
    this.dataListEmptyButtonOnTapDestination,
    required this.dataListEmptyText,
    this.textOnlyIfDataListIsEmpty = false,
    required this.itemBuilder,
    this.floatingActionButton,
  });

  @override
  SectionState createState() => SectionState();
}

class SectionState<T> extends State<Section<T>> {
  @override
  Widget build(BuildContext context) {

    GridView productGrid = GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: widget.dataList.length,
      itemBuilder: (context, index) {
        final Product data = widget.dataList.elementAt(index) as Product;
        return widget.itemBuilder(context, data);
      },
    );

    ListView productList = ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        itemCount: widget.dataList.length,
        itemBuilder: (context, index) {
          final Product data = widget.dataList.elementAt(index) as Product;

          return widget.itemBuilder(context, data);
        }
    );

    SingleChildScrollView body = SingleChildScrollView(
      child: Column(
        children: [
          if (widget.onSearchChanged != null)
            SearchInputField(onSearchChanged: widget.onSearchChanged!),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            child: widget.showChildAsList ? productList : productGrid,
          ),
        ],
      ),
    );

    Widget loadingIndicator = const Center(
      child: CircularProgressIndicator(),
    );

    Center noDataTemplate = Center(
      child: widget.textOnlyIfDataListIsEmpty
          ? Text(widget.dataListEmptyText)
          : widget.dataListEmptyButtonOnTapDestination == null
          ? null
          : ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
            widget.dataListEmptyButtonOnTapDestination!,
          ),
        ),
        child: Text(widget.dataListEmptyText),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.9),
      appBar: POSAppBar(hideActions: widget.hideAppBarActions),
      body: widget.isLoading
          ? loadingIndicator
          : widget.dataList.isEmpty
          ? noDataTemplate
          : body,
      floatingActionButton: widget.floatingActionButton,
    );
  }
}