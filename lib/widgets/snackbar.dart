import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

enum SnackBarType { success, error, info }

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final theme = Theme.of(context);

    // Choose icon and background color based on type
    IconData icon;
    Color backgroundColor;

    switch (type) {
      case SnackBarType.success:
        icon = Pixel.checkdouble;
        backgroundColor = theme.colorScheme.secondary; // App theme secondary
        break;
      case SnackBarType.error:
        icon = Pixel.alert;
        backgroundColor = Colors.redAccent;
        break;
      case SnackBarType.info:
        icon = Pixel.infobox;
        backgroundColor = theme.colorScheme.primary; // App theme primary
        break;
    }

    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: duration,
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Row(
        children: [
          Icon(icon, color: theme.colorScheme.onSecondary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
