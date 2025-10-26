// lib/widgets/animated_nav_bar_item.dart
import 'package:flutter/material.dart';

class AnimatedNavBarItem extends StatefulWidget {
  final IconData iconData;
  final String label;
  final bool isActive;
  final bool isPressed;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;
  final VoidCallback onTapCancel;
  final int index; // For potential debugging

  const AnimatedNavBarItem({
    Key? key,
    required this.iconData,
    required this.label,
    required this.isActive,
    required this.isPressed,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTapDown,
    required this.onTapUp,
    required this.onTapCancel,
    required this.index,
  }) : super(key: key);

  @override
  State<AnimatedNavBarItem> createState() => _AnimatedNavBarItemState();
}

class _AnimatedNavBarItemState extends State<AnimatedNavBarItem> {

  @override
  Widget build(BuildContext context) {
    final Color color = widget.isActive ? widget.activeColor : widget.inactiveColor;
    final double scaleFactor = widget.isPressed ? 0.8 : (widget.isActive ? 1.25 : 0.9);
    final double iconSize = widget.isPressed ? 22 : (widget.isActive ? 28 : 22); 
    final double opacity = (widget.isActive || widget.isPressed) ? 1.0 : 0.7;

    return GestureDetector(
      onTapDown: (_) => widget.onTapDown(),
      onTapUp: (_) => widget.onTapUp(),
      onTapCancel: () => widget.onTapCancel(),
      behavior: HitTestBehavior.opaque, 
      child: Container(
        width: MediaQuery.of(context).size.width / 5, 
        color: Colors.transparent,
        alignment: Alignment.center,

        child: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 200), 
          curve: Curves.easeOut,
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: scaleFactor,
                duration: const Duration(milliseconds: 150), 
                curve: Curves.easeInOut,
                child: Icon( 
                  widget.iconData,
                  size: iconSize,
                  color: color,
                ),
              ),
              const SizedBox(height: 4), 
              // The label text
              Text(
                widget.label,
                maxLines: 1, 
                overflow: TextOverflow.ellipsis, 
                style: TextStyle(
                  color: color, 
                  fontWeight: widget.isActive ? FontWeight.bold : FontWeight.normal, 
                  fontSize: 10, 
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}