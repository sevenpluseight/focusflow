import 'package:flutter/material.dart';

class FormTheme {
  static ThemeData formFieldTheme({bool isDarkMode = true}) {
    return ThemeData(
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: const Color(0xFFBFFB4F),
        selectionColor: const Color(0x55BFFB4F),
        selectionHandleColor: const Color(0xFFBFFB4F),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDarkMode ? const Color(0xFF2C2F33) : Colors.white,
        labelStyle: TextStyle(
          color: isDarkMode ? Colors.white70 : Colors.black87,
        ),
        hintStyle: TextStyle(
          color: isDarkMode ? Colors.white54 : Colors.black45,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.white30 : Colors.black38,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFBFFB4F), width: 2),
        ),
      ),
    );
  }
}
