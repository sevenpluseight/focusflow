import 'package:flutter/material.dart';

class StyledCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final String? title;
  final bool hasBorder;
  final double? width;
  final double? height;
  final double maxHeightFactor;

  const StyledCard({
    Key? key,
    required this.child,
    this.color,
    this.padding,
    this.title,
    this.hasBorder = false,
    this.width,
    this.height,
    this.maxHeightFactor = 0.5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : Colors.black;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final cardWidth = width ?? screenWidth * 0.9;
    final cardMaxHeight = height ?? screenHeight * maxHeightFactor;

    final effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8);

    return Center(
      child: SizedBox(
        width: cardWidth,
        child: Card(
          color: color ?? theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: hasBorder
                ? BorderSide(color: theme.colorScheme.primary, width: 2)
                : BorderSide.none,
          ),
          elevation: 2,
          child: Padding(
            padding: effectivePadding,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 60,
                maxHeight: cardMaxHeight,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                    if (title != null)
                      const SizedBox(height: 4),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}