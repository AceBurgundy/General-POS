import 'package:shared_preferences/shared_preferences.dart';

class AppName {
  static Future<String?> get() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString('app_name');
  }

  static Future<String> set(String newName) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('app_name', newName);

    return newName;
  }
}