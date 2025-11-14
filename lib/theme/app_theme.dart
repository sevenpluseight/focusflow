import 'package:flutter/material.dart';
import 'package:focusflow/theme/form_theme.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFBFFB4F);
  static const Color darkBackground = Color(0xFF222428);
  static const Color lightBackground = Colors.white;

  // Dark theme
  static final ThemeData darkTheme = FormTheme.formFieldTheme(isDarkMode: true).copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    cardColor: const Color(0xFF2C2F33),
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: primaryColor,
      surface: Color(0xFF2C2F33),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
        minimumSize: const Size.fromHeight(52),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide.none,
        ),
      ),
    ),
  );

  // Light theme
  static final ThemeData lightTheme = FormTheme.formFieldTheme(isDarkMode: false).copyWith(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    cardColor: const Color(0xFFE8F5E9),
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: primaryColor,
      surface: const Color(0xFFE8F5E9),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF4F4F4),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      shape: Border(
        bottom: BorderSide(
          color: Colors.grey,
          width: 0.5,
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFF4F4F4),
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black54),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
        minimumSize: const Size.fromHeight(52),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide.none,
        ),
      ),
    ),
  );
}
