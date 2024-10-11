import 'dart:io';

import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../models/cart.dart';
import '../../../models/product.dart';
import '../../../utilities/string_constant.dart';

class GridCartCardWidget extends StatefulWidget {
  final Product product;
  final void Function(String) onDeletePressed;
  final double itemHeight = 90.0;

  const GridCartCardWidget({
    super.key,
    required this.product,
    required this.onDeletePressed
  });

  @override
  ListItemWidgetState createState() => ListItemWidgetState();
}

class ListItemWidgetState extends State<GridCartCardWidget> {
  int _counter = 0;
  int _quantityLeftFromInventory = 0;
  File? _imageFile;

  @override
  void initState() {
    super.initState();

    setState(() {
      _counter = widget.product.cartQuantity;
      _quantityLeftFromInventory = widget.product.quantity;
    });

    _loadImage();
  }

  void _loadImage() async {
    File image = await getImage(widget.product.imageFileName);

    setState(() {
      _imageFile = image;
    });
  }

  Widget _buildOptionButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: IconButton(
        iconSize: 15,
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    SizedBox leading = SizedBox(
      height: widget.itemHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildOptionButton(Icons.delete_forever, () =>
              widget.onDeletePressed(widget.product.id)
          )
        ],
      ),
    );

    ClipRRect leadingImage = ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: _imageFile != null
          ? Image.file(
              _imageFile!,
              height: widget.itemHeight,
              width: MediaQuery.of(context).size.width * 0.25,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: widget.itemHeight,
                  width: MediaQuery.of(context).size.width * 0.25,
                  color: Colors.grey[200],
                );
              },
            )
          : Container(
              height: widget.itemHeight,
              width: MediaQuery.of(context).size.width * 0.25,
              color: Colors.grey[200],
              child: const Icon(
                Icons.image,
                color: Colors.grey,
                size: 40,
              ),
            ),
    );

    Column titleSubtitle = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text("Quantity: $_counter"),
        Text(widget.product.name),
        const Text("")
      ],
    );

    IntrinsicWidth trailing = IntrinsicWidth(
      child: SizedBox(
        height: widget.itemHeight,
        child: SizedBox(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  asCurrency(widget.product.price * _counter),
                  style: const TextStyle(fontSize: 15.0),
                ),
                const Text(""),
                Row(
                  children: [
                    _buildOptionButton(Icons.remove, () async {
                      if (_counter == 0) {
                        return;
                      }

                      int newCount = await Cart.reduceProductCount(product: widget.product, gridItemContext: context);

                      setState(() {
                        _counter = newCount;
                      });

                      _quantityLeftFromInventory = widget.product.quantity;
                    }),
                    const SizedBox(width: 10),
                    _buildOptionButton(Icons.add, () async {
                      if (_counter >= _quantityLeftFromInventory) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text(Texts.reachedAllowableLimit)),
                        );
                        return;
                      }

                      int newCount = await Cart.increaseProductCount(product: widget.product, gridItemContext: context);

                      setState(() {
                        _counter = newCount;
                      });
                    }),
                  ]
                )
              ]
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            leading,
            const SizedBox(width: 10),
            leadingImage,
            const SizedBox(width: 10),
            titleSubtitle,
            const Spacer(),
            trailing
          ],
        ),
      ),
    );
  }
}
