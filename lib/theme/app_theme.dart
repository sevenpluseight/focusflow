import 'package:flutter/material.dart';
import 'package:focusflow/theme/form_theme.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF0BAE65); // Fresh green accent
  static const Color darkBackground = Color(0xFF222428);
  static const Color lightBackground = Color(0xFFF7F7F7); // Warm light-gray

  // Leaderboard colors
  static const Color goldColor = Colors.amber;
  static const Color silverColor = Colors.grey;
  static const Color bronzeColor = Color(0xFFCD7F32);

  // Dark theme
  static final ThemeData darkTheme = FormTheme.formFieldTheme(isDarkMode: true).copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    cardColor: const Color(0xFF2C2F33),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFBFFB4F), // Lime green for dark theme
      onPrimary: Colors.black, // Explicitly set for lime green primary
      secondary: Color(0xFFBFFB4F), // Lime green for dark theme
      tertiary: Colors.orangeAccent, // Added tertiary color for warnings
      surface: Color(0xFF2C2F33),
      outlineVariant: Colors.white30, // Light gray for borders in dark mode
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
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFBFFB4F), // Lime green for dark theme
        foregroundColor: Colors.black,
        minimumSize: const Size.fromHeight(52),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide.none,
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF2C2F33), // Lighter dark background for dark mode
      selectedItemColor: Color(0xFFBFFB4F), // Lime green for selected item
      unselectedItemColor: Colors.white70, // White70 for unselected item
    ),
  );

  // Light theme
  static final ThemeData lightTheme = FormTheme.formFieldTheme(isDarkMode: false).copyWith(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground, // #F7F7F7
    cardColor: Colors.white, // pure white #FFFFFF
    colorScheme: const ColorScheme.light(
      primary: primaryColor, // fresh green #0BAE65
      onPrimary: Colors.black, // Explicitly set for green primary
      secondary: primaryColor, // fresh green #0BAE65
      tertiary: Colors.orangeAccent, // Added tertiary color for warnings
      surface: Colors.white, // pure white #FFFFFF
      onSurface: Color(0xFF222222), // darker gray for general text
      outlineVariant: Colors.grey, // Light gray for borders in light mode
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white, // white #FFFFFF
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF222222)), // darker gray for icons
      titleTextStyle: TextStyle(
        color: Color(0xFF222222), // darker gray for title
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      shape: Border(
        bottom: BorderSide(
          color: Colors.transparent, // Remove border for cleaner look
          width: 0,
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white, // white #FFFFFF
      selectedItemColor: primaryColor, // fresh green #0BAE65
      unselectedItemColor: Colors.grey,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF222222)), // darker gray
      bodyMedium: TextStyle(color: Color(0xFF222222)), // darker gray
      titleLarge: TextStyle(color: Color(0xFF222222), fontWeight: FontWeight.bold, fontSize: 22), // darker gray
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor, // fresh green #0BAE65
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
