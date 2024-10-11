import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../constants.dart';

/// Represents a product in the store, including its quantity, price, and
/// associated cart details.
class Product {
  String id;
  String imageFileName;
  int quantity;
  String name;
  double price;
  int cartQuantity;
  double cartTotal;

  /// Creates a new `Product` object.
  ///
  /// If the [id] is not provided, a UUID is generated. The [imageFileName], [quantity],
  /// [name], and [price] are required. [cartQuantity] and [cartTotal] are optional
  /// and default to 0.
  Product({
    required this.id,
    required this.imageFileName,
    required this.quantity,
    required this.name,
    required this.price,
    this.cartQuantity = 0,
    this.cartTotal = 0,
  });

  /// Converts the `Product` object to a JSON map.
  ///
  /// The returned map contains all properties of the product such as id,
  /// image path, quantity, name, price, cart quantity, and cart total.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['imageFileName'] = imageFileName;
    data['quantity'] = quantity;
    data['name'] = name;
    data['price'] = price;
    data['cartQuantity'] = cartQuantity;
    data['cartTotal'] = cartTotal;

    return data;
  }

  /// Increases the product's quantity by 1 and saves the updated product data
  /// in the Hive store.
  ///
  /// Returns the updated quantity of the product.
  Future<int> addQuantity() async {
    quantity++;
    save();

    return quantity;
  }

  /// Decreases the product's quantity by 1 if it's greater than 0 and saves
  /// the updated product data in the Hive store.
  ///
  /// Returns the updated quantity of the product. If the quantity is 0 or less,
  /// it will return 0 without modifying the store.
  Future<int> reduceQuantity() async {
    if (quantity <= 0) {
      return 0;
    }

    quantity--;
    save();

    return quantity;
  }

  /// Updates the product data with new information provided in [newProductData]
  /// and saves it to the Hive store.
  Future<void> update(Product newProductData) async {
    Box<dynamic> store = await Hive.openBox('store');
    var products = store.get('products', defaultValue: []);

    int oldProductIndex = products.indexWhere(
      (oldProduct) => oldProduct['id'] == newProductData.id
    );

    products[oldProductIndex] = newProductData.toJson();
    await store.put('products', products);
  }

  /// Saves the current product data to the Hive store. If the product already
  /// exists in the store, it will be updated.
  Future<void> save() async {
    Box<dynamic> store = await Hive.openBox('store');
    var products = store.get('products', defaultValue: []);

    int savedProductIndex = products.indexWhere(
      (product) => product['id'] == id
    );

    if (savedProductIndex == -1) {
      return;
    }

    products[savedProductIndex] = toJson();
    await store.put('products', products);
  }

  /// Creates a new product entry in the Hive store and copies its image to
  /// the documents directory.
  ///
  /// The image is saved as a file with a hashed filename to avoid conflicts.
  Future<void> create() async {
    Box<dynamic> store = await Hive.openBox('store');
    var products = store.get('products', defaultValue: []);

    products.add(toJson());

    await store.put('products', products);
  }

  /// Deletes the product from the Hive store.
  Future<bool> delete() async {
    Box<dynamic> store = await Hive.openBox('store');
    var products = store.get('products', defaultValue: []);

    int productIndex = products.indexWhere((product) => product['id'] == id);

    if (productIndex == -1) {
      return false;
    }

    var product = products[productIndex];

    // Removing the product from Hive
    products.removeAt(productIndex);
    await store.put('products', products);

    // Delete the associated image file
    if (product['imageFileName'] != null) {
      File image = await getImage(product['imageFileName']);
      bool fileExist = await image.exists();

      if (fileExist) {
        await image.delete();
      }
    }

    return true;
  }
}

/// Static class providing methods to manage `Product` objects.
class Products {

  /// Fetches all products from the Hive store.
  ///
  /// If [whereName] is provided, it filters products whose name contains the
  /// given string (case-insensitive).
  ///
  /// Returns a list of `Product` objects.
  static Future<List<Product>> all({ String? whereName }) async {
    Box<dynamic> store = await Hive.openBox('store');
    List<dynamic> products = store.get('products', defaultValue: []);

    if (whereName != null) {
      List<Product> filteredProducts = [];
      String searchValue = whereName.toLowerCase();

      // Filter items based on search criteria
      for (var product in products) {
        if (product['name'].toString().toLowerCase().contains(searchValue)) {
          filteredProducts.add(Product(
              id: product['id'],
              imageFileName: product['imageFileName'],
              quantity: product['quantity'],
              name: product['name'],
              price: product['price'],
              cartQuantity: product['cartQuantity'],
              cartTotal: product['cartTotal']
          ));
        }
      }

      return filteredProducts;
    }

    return products.map((product) => Product(
        id: product['id'],
        imageFileName: product['imageFileName'],
        quantity: product['quantity'],
        name: product['name'],
        price: product['price'],
        cartQuantity: product['cartQuantity'],
        cartTotal: product['cartTotal']
    )).toList();
  }

  /// Fetches a single product by its [id] from the Hive store.
  ///
  /// Returns the `Product` object if found, or `null` if no product with the
  /// given ID exists.
  static Future<Product?> get({ required String id }) async {
    Box<dynamic> store = await Hive.openBox('store');
    var products = store.get('products', defaultValue: []);

    try {
      var foundProduct = products.firstWhere(
        (product) => product['id'] == id
      );

      return Product(
          id: foundProduct['id'],
          imageFileName: foundProduct['imageFileName'],
          quantity: foundProduct['quantity'],
          name: foundProduct['name'],
          price: foundProduct['price'],
          cartQuantity: foundProduct['cartQuantity'],
          cartTotal: foundProduct['cartTotal']
      );
    } catch (error) {
      if (kDebugMode) {
        print("called $error");
      }

      return null;
    }
  }
}
