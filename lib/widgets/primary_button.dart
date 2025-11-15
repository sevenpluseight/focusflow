import 'package:flutter/material.dart';
import 'package:focusflow/utils/utils.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;

  const PrimaryButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;

    return ElevatedButton(
      onPressed: onPressed,
      style: style ??
          ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            elevation: 2,
            foregroundColor: Colors.black,
            minimumSize: Size(double.infinity, SizeConfig.hp(6)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
      child: DefaultTextStyle(
        style: text.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: SizeConfig.font(2),
              color: Colors.black,
            ) ??
            const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
        child: child,
      ),
    );
  }
}
