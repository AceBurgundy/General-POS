import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeColor {
  orange,
  purple,
  green,
  red;

  @override
  String toString() {
    return name;
  }
}

class AppTheme {

  // Private fields for ThemeData
  static final ThemeData orangeTheme = ThemeData(
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: const MaterialColor(
        0xFFE65100,
        {
          50: Color(0xFFFFF3E0),
          75: Color(0xFFFFEAC9),
          100: Color(0xFFFFE0B2),
          200: Color(0xFFFFCC80),
          300: Color(0xFFFFB74D),
          400: Color(0xFFFFA726),
          500: Color(0xFFFF9800), 
          600: Color(0xFFFF9800),
          700: Color(0xFFF57C00),
          800: Color(0xFFEF6C00),
          900: Color(0xFFE64500),
          1000: Color(0xFFFF9100),
        },
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFFE65100),
      ),
    ),
    cardColor: Colors.white,
    splashColor: const Color(0xFFFF9100),
    focusColor: const Color(0xFFFFAB40),
  );

  static final ThemeData purpleTheme = ThemeData(
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: const MaterialColor(
        0xFF6A1B9A,
        {
          50: Color(0xFFF3E5F5),
          75: Color(0xFFE1BEE7),
          100: Color(0xFFCE93D8),
          200: Color(0xFFBA68C8),
          300: Color(0xFFAB47BC),
          400: Color(0xFF9C27B0),
          500: Color(0xFF8E24AA), 
          600: Color(0xFF8E24AA),
          700: Color(0xFF7B1FA2),
          800: Color(0xFF6A1B9A),
          900: Color(0xFF4A148C),
          1000: Color(0xFF9C27B0),
        },
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF6A1B9A),
      ),
    ),
    cardColor: Colors.white,
    splashColor: const Color(0xFF9C27B0),
    focusColor: const Color(0xFFAB47BC),
  );

  static final ThemeData redTheme = ThemeData(
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: const MaterialColor(
        0xFFD32F2F,
        {
          50: Color(0xFFFEEEEE),
          75: Color(0xFFE57373),
          100: Color(0xFFF44336),
          200: Color(0xFFE53935),
          300: Color(0xFFD32F2F), 
          400: Color(0xFFD32F2F),
          500: Color(0xFFC62828),
          600: Color(0xFFB71C1C),
          700: Color(0xFFC62828),
          800: Color(0xFFD32F2F),
          900: Color(0xFFD50000),
          1000: Color(0xFFFF1744),
        },
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFFD32F2F),
      ),
    ),
    cardColor: Colors.white,
    splashColor: const Color(0xFFD50000),
    focusColor: const Color(0xFFE57373),
  );

  static final ThemeData greenTheme = ThemeData(
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: const MaterialColor(
        0xFF388E3C,
        {
          50: Color(0xFFE8F5E9),
          75: Color(0xFFC8E6C9),
          100: Color(0xFFB2DFDB),
          200: Color(0xFF81C784),
          300: Color(0xFF4CAF50), 
          400: Color(0xFF43A047),
          500: Color(0xFF388E3C),
          600: Color(0xFF388E3C),
          700: Color(0xFF2E7D32),
          800: Color(0xFF1B5E20),
          900: Color(0xFF004D40),
          1000: Color(0xFF5C6BC0),
        },
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF388E3C),
      ),
    ),
    cardColor: Colors.white,
    splashColor: const Color(0xFF5C6BC0),
    focusColor: const Color(0xFF81C784),
  );

  static Future<ThemeData> getThemeData() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String? preferredColorName = preferences.getString('theme_color');

    if (preferredColorName == null) {
      setThemeColor(AppThemeColor.orange);
      return orangeTheme;
    }

    switch (preferredColorName) {
      case "orange":
        return orangeTheme;
      case "purple":
        return purpleTheme;
      case "red":
        return redTheme;
      case "green":
        return greenTheme;
      default:
        return orangeTheme;
    }
  }

  static Future<void> setThemeColor(AppThemeColor colorName) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('theme_color', colorName.toString());
  }
}
