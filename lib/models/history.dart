import 'package:flutter/material.dart';
import 'package:general_pos/constants.dart';
import 'package:general_pos/theme.dart';
import 'package:general_pos/utilities/dates.dart';
import 'package:hive/hive.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

import '../utilities/export.dart';

class HistoryProduct {
  final String name;
  final double price;
  final int quantity;
  final double total;

  HistoryProduct({
    required this.name,
    required this.price,
    required this.quantity,
    required this.total
  });

  /// Converts the [History] object into a JSON-like map.
  ///
  /// Returns:
  /// - A [Map] containing the product list, total amount, and payment date.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['price'] = price;
    data['quantity'] = quantity;
    data['total'] = total;
    return data;
  }
}

/// A class representing a single purchase history entry.
class History {
  /// List of products involved in the transaction.
  List<HistoryProduct> products;

  /// Total amount of the transaction.
  double? total;

  /// Date and time when the transaction was paid.
  DateTime? paidOn;

  /// Constructs a [History] object with the required [products], [total], and [paidOn].
  History({
    required this.products,
    required this.total,
    required this.paidOn,
  });

  /// Converts the [History] object into a JSON-like map.
  ///
  /// Returns:
  /// - A [Map] containing the product list, total amount, and payment date.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['products'] = products;
    data['total'] = total;
    data['paidOn'] = paidOn;

    return data;
  }

  /// Adds the current [History] entry to the store.
  ///
  /// This method opens the Hive box called 'store' and appends the current
  /// history data to the existing 'history' list.
  Future<void> create() async {
    Box<dynamic> store = await Hive.openBox('store');
    var history = store.get('history', defaultValue: []);

    final currentHistoryEntry = {
      'products': products.map((product) => product.toJson()).toList(),
      'total': total,
      'paidOn': paidOn,
    };

    history.add(currentHistoryEntry);
    store.put('history', history);
  }
}

/// A utility class for handling multiple history entries.
class Histories {

  /// Retrieves all purchase history records from the Hive store.
  ///
  /// Returns:
  /// - A [Future] that resolves to a [List] of [History] objects.
  static Future<List<History>> all() async {
    Box<dynamic> store = await Hive.openBox('store');
    var historyList = store.get('history', defaultValue: []);

    // Maps through each history record
    List<History> histories = historyList.map<History>((history) {
      var products = history['products'] as List<dynamic>;

      /// and for history record, convert the list of product json into list of HistoryProduct instances
      List<HistoryProduct> productHistoryList = products
          .map<HistoryProduct>((product) => HistoryProduct(
                name: product['name'],
                price: double.parse(product['price'].toString()),
                quantity: product['quantity'],
                total: double.parse(product['total'].toString())
            ))
          .toList();

      return History(
        products: productHistoryList,
        total: history['total'],
        paidOn: history['paidOn']
      );
    }).toList();

    return histories;
  }

  /// Exports the history records to a CSV file.
  ///
  /// Parameters:
  /// - [history]: A list of [History] records to be exported.
  ///
  /// The function uses the `to_csv` package to generate a CSV file
  /// with headers derived from the keys of the history records.
  static Future<String> exportRecords(List<History> history) async {

    List<List<String>> records = [];

    for (History record in history) {
      // Row 0: Empty, 'Name', 'Quantity', 'Total', repeated for each product
      List<String> headerRow = ['', ''];
      for (var _ in record.products) {
        headerRow.addAll(['', 'Name', 'Price', 'Quantity', 'Total']);
      }
      records.add(headerRow);

      List<String> productRow = ['', 'Products', ''];

      for (HistoryProduct product in record.products) {
        productRow.addAll([
          product.name,
          asCurrency(product.price),
          product.quantity.toString(),
          asCurrency(product.total),
          ''
        ]);
      }

      records.add(productRow);
      records.add(['', 'Total', '', asCurrency(record.total!)]);
      records.add(['', 'Date Paid', '', formattedDateTime(record.paidOn.toString())]);
    }

    // Create an Excel document (workbook)
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    // Set each column width
    for (int columnIndex = 0; columnIndex < records[0].length; columnIndex++) {
      bool firstOrThirdColumn = columnIndex == 0 || columnIndex == 2;
      bool everyFifthColumnAfterThird = (columnIndex > 2 && (columnIndex - 2) % 5 == 0);

      if (firstOrThirdColumn || everyFifthColumnAfterThird) {
        sheet.setColumnWidthInPixels(columnIndex + 1, 15);
      } else if (columnIndex == 1) {
        sheet.setColumnWidthInPixels(columnIndex + 1, 80);
      } else {
        sheet.setColumnWidthInPixels(columnIndex + 1, 170);
      }
    }

    // Set row height
    for (int rowIndex = 0; rowIndex < records.length; rowIndex++) {
      sheet.setRowHeightInPixels(rowIndex + 1, 30);
    }

    Style cellAlignment = workbook.styles.add('style');
    cellAlignment.hAlign = HAlignType.left;
    cellAlignment.vAlign = VAlignType.center;

    // Populate the Excel sheet with records
    for (int rowIndex = 0; rowIndex < records.length; rowIndex++) {
      List<String> row = records[rowIndex];
      for (int columnIndex = 0; columnIndex < row.length; columnIndex++) {
        String cellValue = row[columnIndex];
        // Set the cell value in the Excel sheet
        sheet.getRangeByIndex(rowIndex + 1, columnIndex + 1).cellStyle = cellAlignment;
        sheet.getRangeByIndex(rowIndex + 1, columnIndex + 1).setText(" $cellValue");
      }
    }

    String getHexColor(Color color) {
      return '#${(color.value & 0x00FFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
    }

    ThemeData appTheme = await AppTheme.getThemeData();

    Style colouredCell = workbook.styles.add('back_style');
    colouredCell.backColor = getHexColor(appTheme.primaryColor);

    // Set each fifth column after third and the third column to the app primary color
    for (int columnIndex = 0; columnIndex < records[0].length; columnIndex++) {
      bool isThirdColumn = (columnIndex == 2);
      bool isFifthColumnAfterThird = (columnIndex > 2 && (columnIndex - 2) % 5 == 0);

      if (isThirdColumn || isFifthColumnAfterThird) {
        for (int rowIndex = 0; rowIndex < records.length; rowIndex++) {
          sheet.getRangeByIndex(rowIndex + 1, columnIndex + 1).cellStyle = colouredCell;
        }
      }
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    return await exportFile(bytes, 'records.xlsx');
  }
}
