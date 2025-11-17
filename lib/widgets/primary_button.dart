import 'package:flutter/material.dart';
import 'package:focusflow/utils/utils.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? text; // New: Optional text for the button
  final Widget? child; // Modified: child is now optional
  final ButtonStyle? style;
  final bool isLoading; // New: To show loading indicator

  const PrimaryButton({
    Key? key,
    required this.onPressed,
    this.text,
    this.child,
    this.style,
    this.isLoading = false,
  }) : assert(text != null || child != null, 'Text or child must be provided for PrimaryButton'),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme;

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed, // Disable button when loading
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
      child: isLoading
          ? SizedBox(
              width: SizeConfig.font(2.5),
              height: SizeConfig.font(2.5),
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 2,
              ),
            )
          : DefaultTextStyle(
              style: textStyle.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: SizeConfig.font(2),
                    color: Colors.black,
                  ) ??
                  const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
              child: child ?? Text(text!), // Use child if provided, else text
            ),
    );
  }
}
