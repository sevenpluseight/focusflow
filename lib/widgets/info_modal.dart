import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

class _InfoDialogContent extends StatelessWidget {
  final String title;
  final Widget? content;
  final String? contentText;

  const _InfoDialogContent({
    Key? key,
    required this.title,
    this.content,
    this.contentText,
  })  : assert(content == null || contentText == null,
            'Cannot provide both content and contentText'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: content ??
          (contentText != null
              ? Text(
                  contentText!,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                )
              : null),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Close',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}

class InfoIcon extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final double? iconSize;
  final String dialogTitle;
  final Widget? dialogContent;
  final String? dialogContentText;

  const InfoIcon({
    Key? key,
    this.icon = Pixel.infobox,
    this.iconColor,
    this.iconSize,
    required this.dialogTitle,
    this.dialogContent,
    this.dialogContentText,
  })  : assert(dialogContent == null || dialogContentText == null,
            'Cannot provide both dialogContent and dialogContentText'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return IconButton(
      icon: Icon(
        icon,
        color: iconColor ?? (isDark ? Colors.white70 : Colors.black54),
        size: iconSize,
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return _InfoDialogContent(
              title: dialogTitle,
              content: dialogContent,
              contentText: dialogContentText,
            );
          },
        );
      },
    );
  }
}