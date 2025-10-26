import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

enum SnackBarType { success, error, info }
enum SnackBarPosition { top, bottom }

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    SnackBarPosition position = SnackBarPosition.bottom,
    Duration duration = const Duration(seconds: 3),
  }) {
    final theme = Theme.of(context);
    final overlay = Overlay.of(context);

    IconData icon;
    Color backgroundColor;

    switch (type) {
      case SnackBarType.success:
        icon = Pixel.checkdouble;
        backgroundColor = Colors.greenAccent.shade700;
        break;
      case SnackBarType.error:
        icon = Pixel.alert;
        backgroundColor = Colors.redAccent.shade700;
        break;
      case SnackBarType.info:
        icon = Pixel.infobox;
        backgroundColor = theme.colorScheme.primary;
        break;
    }

    if (position == SnackBarPosition.bottom) {
      final snackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: duration,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            Icon(icon, color: theme.colorScheme.onSecondary, size: 26),
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
      return;
    }

    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: _AnimatedTopSnackBar(
          icon: icon,
          message: message,
          backgroundColor: backgroundColor,
          textColor: theme.colorScheme.onSecondary,
          duration: duration,
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(duration).then((_) => entry.remove());
  }
}

class _AnimatedTopSnackBar extends StatefulWidget {
  final IconData icon;
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final Duration duration;

  const _AnimatedTopSnackBar({
    required this.icon,
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    required this.duration,
  });

  @override
  State<_AnimatedTopSnackBar> createState() => _AnimatedTopSnackBarState();
}

class _AnimatedTopSnackBarState extends State<_AnimatedTopSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _animation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(16),
        color: widget.backgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(widget.icon, color: widget.textColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.message,
                  style: TextStyle(
                    color: widget.textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}