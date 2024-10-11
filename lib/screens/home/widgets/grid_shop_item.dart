import 'dart:io';
import 'package:flutter/material.dart';
import 'package:general_pos/utilities/string_constant.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../models/cart.dart';
import '../../../models/product.dart';
import '../../../utilities/providers/cart_item_counter.dart';

class GridShopCardWidget extends StatefulWidget {
  final Product product;

  const GridShopCardWidget({
    super.key,
    required this.product
  });

  @override
  ListItemWidgetState createState() => ListItemWidgetState();
}

class ListItemWidgetState extends State<GridShopCardWidget> {
  File? _imageFile;
  bool _outOfStock = false;

  @override
  void initState() {
    super.initState();
    _loadImage();

    _outOfStock = int.parse(widget.product.quantity.toString()) <= 0;
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
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: Stack(
          children: [
            _imageFile != null
                ? Image.file(
                    _imageFile!,
                    width: double.infinity,
                    height: 130,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 130,
                        color: Colors.grey[200],
                      );
                    }
                  )
                : Container(
                    width: double.infinity,
                    height: 130,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, color: Colors.grey, size: 40),
                  ),

            if (_outOfStock)
              Container(
                width: double.infinity,
                height: 130,
                color: Colors.black54,
                alignment: Alignment.center,
                child: const Text(
                  Texts.outOfStock,
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        )
    );
    
    Padding info = Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.name,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15.0)
          ),
          Text(
            asCurrency(widget.product.price),
            style: const TextStyle(fontSize: 15.0),
          )
        ],
      ),
    );
    
    Positioned addToCartButton = Positioned(
      top: 5,
      right: 5,
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: IconButton(
              iconSize: 15,
              icon: const Icon(Icons.shopping_cart_sharp, color: Colors.white),
              onPressed: () {
                Cart.addProduct(widget.product);

                if (mounted) {
                  Provider.of<CartItemCounter>(context, listen: false).updateCartItemCount();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${widget.product.name} added to cart')),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
    
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 0, // no shadow
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [image, info],
          ),
          if (!_outOfStock) addToCartButton
        ],
      ),
    );
  }
}
