import 'dart:io';
import 'package:general_pos/onboarded.dart';
import 'package:general_pos/utilities/export.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

Future<String> productImageDirectory() async {
  final directory = await getDownloadsDirectory();
  return directory!.path;
}

Future<File> getImage(String fileName) async {
  return File('${await productImageDirectory()}/$fileName');
}

/// Converts a double to a prettified peso value
String asCurrency(double value) {
  return "₱ ${value.toStringAsFixed(2)}";
}

Future<void> clearApp() async {
  Box<dynamic> store = Hive.box('store');
  String imageDirectoryPath = await productImageDirectory();
  Directory imageDirectory = Directory(imageDirectoryPath);
  bool directoryExist = await imageDirectory.exists();

  if (!directoryExist) {
    await store.clear();
    return;
  }

  final List<FileSystemEntity> files = imageDirectory.listSync();

  for (FileSystemEntity file in files) {
    if (file is File) {
      await file.delete();
    }
  }

  await store.clear();
  removeSaveDirectory();
  Onboarded.setOnboardedStatus(false);
}