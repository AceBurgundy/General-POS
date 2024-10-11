import 'package:shared_preferences/shared_preferences.dart';

class Onboarded {
  static Future<bool?> getOnboardedStatus() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool('onboarded');
  }

  static void setOnboardedStatus(bool status) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool('onboarded', status);
  }
}