import 'package:flutter/material.dart';

class AnimatedNavBarItem extends StatefulWidget {
  final IconData iconData;
  final String label;
  final bool isActive;
  final int index;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;

  const AnimatedNavBarItem({
    Key? key,
    required this.iconData,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.index,
    required this.activeColor,
    required this.inactiveColor,
  }) : super(key: key);

  @override
  State<AnimatedNavBarItem> createState() => _AnimatedNavBarItemState();
}

class _AnimatedNavBarItemState extends State<AnimatedNavBarItem> {
  bool _isPressed = false;

  void _onTapDown(_) {
    setState(() => _isPressed = true);
  }

  void _onTapUp(_) {
    setState(() => _isPressed = false);
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final Color color = widget.isActive ? widget.activeColor : widget.inactiveColor;
    final double scaleFactor = _isPressed ? 0.8 : (widget.isActive ? 1.25 : 0.9);
    final double iconSize = _isPressed ? 22 : (widget.isActive ? 28 : 22);
    final double opacity = (widget.isActive || _isPressed) ? 1.0 : 0.7;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: MediaQuery.of(context).size.width / 5,
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
