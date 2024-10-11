import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:general_pos/models/product.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../utilities/providers/total_amount.dart';
import 'history.dart';

/// This class manages cart operations, including adding products, paying,
/// removing products, and adjusting product quantities in a cart.
class Cart {
  /// Converts a list of product IDs into a list of [Product] objects.
  ///
  /// Takes a list of product IDs [cartIds], and maps each ID to its respective
  /// product by calling `Products.get`. Returns a list of [Product] objects.
  static Future<List<Product>> cartIdToProducts(List<String> cartIds) async {
    // Use Future.wait to wait for all Futures to complete
    List<Product?> products = await Future.wait(
        cartIds.map((productId) => Products.get(id: productId))
    );

    // Remove null products
    return products.where((product) => product != null).cast<Product>().toList();
  }

  /// Retrieves all products in the cart. Optionally, filters the products by
  /// their name using the [whereName] parameter.
  ///
  /// Opens the Hive store and retrieves the product IDs stored in the cart.
  /// If [whereName] is provided, it filters the cart products by checking if
  /// the product name contains the specified string (case-insensitive).
  ///
  /// Returns a list of [Product] objects.
  static Future<List<Product>> all({String? whereName}) async {
    Box<dynamic> store = await Hive.openBox('store');
    List<dynamic> cartIds = store.get('cart', defaultValue: []);
    List<Product> convertedCartProducts = await cartIdToProducts(cartIds.cast<String>());

    if (whereName == null) {
      return convertedCartProducts;
    }

    List<Product> filteredConvertedProducts = [];

    for (Product product in convertedCartProducts) {
      if (product.name.toLowerCase().contains(whereName.toLowerCase())) {
        filteredConvertedProducts.add(product);
      }
    }

    return filteredConvertedProducts;
  }

  /// Clears the cart. Must call Cart.pay() before this to pay current fees and reset the items
  static Future<List<Product>> clear() async {
    Box<dynamic> store = await Hive.openBox('store');
    await store.put('cart', []);

    return [];
  }

  /// Returns the total number of items inside the cart.
  ///
  /// Opens the Hive store, retrieves the current cart, then returns the total number of ids
  static Future<int> count() async {
    Box<dynamic> store = await Hive.openBox('store');
    List<dynamic> cartIds = store.get('cart', defaultValue: []);

    return cartIds.length;
  }

  /// Adds a product to the cart by its [Product] object.
  ///
  /// Opens the Hive store, retrieves the current cart, and adds the product's
  /// UUID to the cart. Then, it updates the cart in the store.
  static void addProduct(Product product) async {
    Box<dynamic> store = await Hive.openBox('store');
    var cart = store.get('cart', defaultValue: []);

    product.cartTotal = product.price;
    product.cartQuantity++;
    product.save();

    // Add the UUID of the selected cart item
    cart.add(product.id);
    await store.put('cart', cart);
  }

  /// Handles the payment process, transferring items from the cart to history
  /// and resetting product quantities in the cart.
  ///
  /// Updates each product's cart quantity and total after purchase. It also
  /// resets cart items back to their default states, and adds the cart items to
  /// the purchase history.
  ///
  /// [context] is required for accessing [TotalAmount] using Provider.
  static Future<bool> pay(BuildContext context) async {
    Box<dynamic> store = await Hive.openBox('store');
    var cartIds = store.get('cart', defaultValue: []);

    List<HistoryProduct> cartProducts = [];

    /// Updates the product data after purchase or when resetting the cart.
    ///
    /// If [resetCart] is true, the product's cart quantities are reset to zero.
    /// Otherwise, it adds the product to the list of purchased items.
    Future<bool> updateProductData(String productUUID, {bool resetCart = false}) async {
      Product? item = await Products.get(id: productUUID);

      if (item == null) {
        if (kDebugMode) {
          print('Item with id $productUUID not found');
        }
        return false;  // Return false if item not found
      }

      if (resetCart) {
        // When done paying, the remaining quantity in the inventory,
        // Will be subtracted with the number of items in the cart,
        // before the quantity and total of the item in the cart will reset back to original
        item.quantity -= item.cartQuantity;
        item.cartQuantity = 0;
        item.cartTotal = 0;
        item.save();
      } else {
        HistoryProduct historyProduct = HistoryProduct(
            name: item.name,
            price: item.price,
            quantity: item.quantity,
            total: item.cartTotal
        );

        cartProducts.add(historyProduct);
      }

      return true;
    }

    /// Adds the products in the cart to the purchase history.
    ///
    /// Retrieves the total amount from the [TotalAmount] provider, and adds
    /// the cart products and the total to the history in the store.
    Future<bool> addProductsToHistory() async {
      double total = Provider.of<TotalAmount>(context, listen: false).totalAmount;

      for (var id in cartIds) {
        bool productUpdated = await updateProductData(id);

        if (!productUpdated) {
          return false;
        }
      }

      History newRecord = History(products: cartProducts, total: total, paidOn: DateTime.now());
      newRecord.create();

      return true;
    }

    /// Resets the cart quantities of the products to zero after payment.
    ///
    /// Loops through all cart items and calls `updateProductData` to reset
    /// their cart quantities and totals.
    Future<bool> resetProductCartMapToZero() async {
      for (var id in cartIds) {
        bool productUpdated = await updateProductData(id, resetCart: true);

        if (!productUpdated) {
          return false;
        }
      }

      return true;
    }

    bool productsAdded = await addProductsToHistory();
    bool productsResetSuccessful = await resetProductCartMapToZero();

    return productsAdded && productsResetSuccessful;
  }

  /// Removes a product from the cart by its [id].
  ///
  /// Opens the Hive store, retrieves the current cart, removes the product ID
  /// from the cart, and updates the cart in the store.
  ///
  /// Returns the updated list of [Product] objects in the cart.
  static Future<List<Product>> removeProduct({required String id}) async {
    Box<dynamic> store = await Hive.openBox('store');
    var cartIds = store.get('cart', defaultValue: []);

    cartIds.remove(id);
    store.put('cart', cartIds);

    return cartIdToProducts(cartIds.cast<String>());
  }

  /// Increases the count of a [Product] in the cart and decreases the product's
  /// available stock.
  ///
  /// Updates the product's cart quantity, total, and saves the changes. Also,
  /// updates the total amount displayed using [TotalAmount].
  ///
  /// Returns the updated cart quantity for the product.
  static Future<int> increaseProductCount({
    required Product product,
    required BuildContext gridItemContext,
  }) async {
    product.cartQuantity++;
    product.cartTotal = product.cartQuantity * product.price;
    product.save();

    Provider.of<TotalAmount>(gridItemContext, listen: false).displayTotalAmount();
    return product.cartQuantity;
  }

  /// Decreases the count of a [Product] in the cart and increases the product's
  /// available stock.
  ///
  /// Updates the product's cart quantity, total, and saves the changes. Also,
  /// updates the total amount displayed using [TotalAmount].
  ///
  /// Returns the updated cart quantity for the product.
  static Future<int> reduceProductCount({
    required Product product,
    required BuildContext gridItemContext,
  }) async {
    product.cartQuantity--;
    product.cartTotal = product.cartQuantity * product.price;
    product.save();

    Provider.of<TotalAmount>(gridItemContext, listen: false).displayTotalAmount();
    return product.cartQuantity;
  }

  /// Calculates and returns the total cart amount.
  ///
  /// Retrieves all products in the cart and sums their [cartTotal] values.
  ///
  /// Returns the total price of all products in the cart as a [double].
  static Future<double> total() async {
    Box<dynamic> store = await Hive.openBox('store');
    var cartIds = store.get('cart', defaultValue: []);
    List<Product> cartProducts = await cartIdToProducts(cartIds.cast<String>());
    double total = 0;

    for (Product product in cartProducts) {
      total += product.cartTotal;
    }

    return total;
  }
}
