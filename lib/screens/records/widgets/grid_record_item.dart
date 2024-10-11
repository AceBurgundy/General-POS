import 'dart:io';

import 'package:flutter/material.dart';
import 'package:general_pos/models/product.dart';

import '../../../constants.dart';

class GridRecordCardWidget extends StatefulWidget {
  final Product product;
  final void Function({ String? searchName }) refreshRecord;

  const GridRecordCardWidget({
    super.key,
    required this.product, required this.refreshRecord
  });

  @override
  ListItemWidgetState createState() => ListItemWidgetState();
}

class ListItemWidgetState extends State<GridRecordCardWidget> {
  int _quantity = 0;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadImage();

    _quantity = widget.product.quantity;
  }

  void _loadImage() async {
    File image = await getImage(widget.product.imageFileName);

    setState(() {
      _imageFile = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    ClipRRect image = ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      child: _imageFile != null
          ? Image.file(
              _imageFile!,
              width: double.infinity,
              height: 95,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Show a grey background when the image fails to load
                return Container(
                  width: double.infinity,
                  height: 95,
                  color: Colors.grey[200],
                );
              }
            )
          : Container(
              width: double.infinity,
              height: 85,
              color: Colors.grey[200],
              child: const Icon(
                Icons.image,
                color: Colors.grey,
                size: 40,
              ),
            ),
    );

    List<Widget> info = [
      Text(
        widget.product.name,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15.0),
      ),
      Text(
       asCurrency(widget.product.price),
        style: const TextStyle(fontSize: 15.0),
      )
    ];

    Widget buildOptionButton(IconData icon, VoidCallback onPressed) {
      return Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(5)),
          child: IconButton(
            iconSize: 15,
            icon: Icon(icon, color: Colors.white),
            onPressed: onPressed,
          )
      );
    }

    Row options = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(""),
          Row(
              children: [
                Text(_quantity.toString(), style: const TextStyle(fontSize: 16.0)),
                const SizedBox(width: 10),
                buildOptionButton(Icons.delete_forever, () async {
                  bool deleted = await widget.product.delete();

                  if (mounted) {
                    if (deleted) widget.refreshRecord();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(
                        deleted ? 'Product deleted successfully!' : 'Failed to delete product'
                      )),
                    );
                  }
                }),
                const SizedBox(width: 10),
                buildOptionButton(Icons.remove, () async {
                  int newQuantity = await widget.product.reduceQuantity();

                  setState(() {
                    _quantity = newQuantity;
                  });
                }),
                const SizedBox(width: 10),
                buildOptionButton(Icons.add, () async {
                  int newQuantity = await widget.product.addQuantity();

                  setState(() {
                    _quantity = newQuantity;
                  });
                })
              ]
          )
        ]
    );

    Padding body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...info,
              const SizedBox(height: 8),
              options
            ]
        )
    );

    return Card(
      color: Colors.grey.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [image, body],
        ),
      ),
    );
  }
}
