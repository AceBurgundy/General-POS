import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens a dialog to prompt the user to select a directory for saving files.
///
/// Returns the selected directory path as a [String].
/// If the user cancels the dialog, an empty string is returned.
Future<String> _showGetDirectoryDialog() async {
  String? path = await FilePicker.platform.getDirectoryPath(
    dialogTitle: 'Choose where to save your file',
  );

  if (path == null) {
    if (kDebugMode) {
      print('Cancelled folder selection');
    }
    return '';
  }

  return path;
}

/// Requests storage permission if not granted and prompts the user to select a save directory.
///
/// The selected directory is stored in shared preferences under the key `save_directory`.
/// Returns the selected directory path as a [String].
/// Throws an [Exception] if permission is denied.
Future<String?> updateSaveDirectory() async {

  final SharedPreferences preferences = await SharedPreferences.getInstance();
  String? directory = preferences.getString('save_directory');
  directory = await _showGetDirectoryDialog();

  preferences.setString('save_directory', directory);
  return directory;
}

/// Retrieves the previously saved directory path from shared preferences.
///
/// Returns the saved directory path as a [String], or `null` if no directory has been saved.
Future<String?> getSavedDirectory() async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getString('save_directory');
}

/// Removes the saved path to files
void removeSaveDirectory() async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString('save_directory', '');
}

/// Exports a file with the given [bytes] and [filename] to a user-specified directory.
///
/// This function attempts to save a file by writing the provided [bytes] to a file
/// in the designated directory. If the directory path is empty or invalid, the user
/// is prompted to update the save directory. If the directory is still empty after
/// an update attempt, the export fails with an error message.
///
/// The function also checks for storage permissions. If permission is not granted,
/// it requests the necessary permissions from the user. If permission is denied,
/// the function returns a 'Permission Denied' message.
///
/// If the file write is successful, the function returns 'Exported'. If an error
/// occurs during the file write operation, the directory path is removed, and an
/// error message is returned explaining that the folder must be created inside
/// the user's download folder.
///
/// Returns a [Future<String>] that indicates the status of the export operation:
/// - 'Exported' if successful
/// - 'Permission Denied' if storage permission is not granted
/// - An error message if the export fails due to directory issues or file writing errors.
///
/// Example:
/// ```dart
/// List<int> fileBytes = [/* file data */];
/// String filename = "example.pdf";
/// String result = await exportFile(fileBytes, filename);
/// print(result); // Outputs: 'Exported' or an error message
/// ```
Future<String> exportFile(List<int> bytes, String filename) async {
  Future<String> saveFile() async {
    String? directory = await getSavedDirectory();

    // First attempt to update directory
    if (directory == '') {
      directory = await updateSaveDirectory();
    }

    // Check again if the user did not update directory
    if (directory == '') {
      return 'Cannot export file to an empty path';
    }

    final File file = File('$directory/$filename');

    try {
      await file.writeAsBytes(bytes, flush: true);
      return 'Exported';

    } catch (error) {
      if (kDebugMode) {
        print("$error");
      }

      removeSaveDirectory();
      return 'For security reasons, folder must be created inside your download folder';
    }
  }

  var status = await Permission.storage.status;

  if (!status.isGranted) {
    status = await Permission.storage.request();

    if (!status.isGranted) {
      return 'Permission Denied';
    }

    return saveFile();
  }

  return saveFile();
}
