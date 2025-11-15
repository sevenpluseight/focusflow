import 'package:flutter/material.dart';
import 'package:focusflow/utils/utils.dart';

class SecondaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;

  const SecondaryButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return OutlinedButton(
      onPressed: onPressed,
      style: style ??
          OutlinedButton.styleFrom(
            minimumSize: Size(double.infinity, SizeConfig.hp(6)),
            side: BorderSide(color: colors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
      child: DefaultTextStyle(
        style: text.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: SizeConfig.font(2),
              color: isDarkMode ? colors.primary : Colors.black,
            ) ??
            TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDarkMode ? colors.primary : Colors.black,
            ),
        child: child,
      ),
    );
  }
}
