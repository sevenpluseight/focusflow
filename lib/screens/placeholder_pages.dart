// lib/screens/placeholder_pages.dart
import 'package:flutter/material.dart';

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the theme's background color
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    return Container(
      color: backgroundColor,
      child: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 24, color: Colors.white), // Ensure text is visible
        ),
      ),
    );
  }
}