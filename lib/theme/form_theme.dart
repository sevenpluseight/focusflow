import 'package:flutter/material.dart';

class FormTheme {
  static ThemeData formFieldTheme() {
    return ThemeData(
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Color(0xFFBFFB4F),
        selectionColor: Color(0x55BFFB4F),
        selectionHandleColor: Color(0xFFBFFB4F),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white10,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFBFFB4F), width: 2),
        ),
      ),
    );
  }
}
