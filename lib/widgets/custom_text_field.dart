import 'package:flutter/material.dart';
import 'package:focusflow/utils/utils.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData? icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;
  final int? maxLines;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.onChanged,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      maxLines: maxLines,
      style: text.bodyLarge?.copyWith(
        color: colors.onSurface,
        fontSize: SizeConfig.font(2),
      ),
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: colors.surface,
        labelStyle: text.bodyMedium?.copyWith(
          color: colors.onSurface.withAlpha((255 * 0.8).toInt()),
          fontSize: SizeConfig.font(2),
        ),
        hintStyle: text.bodyMedium?.copyWith(
          color: colors.onSurface.withAlpha((255 * 0.6).toInt()),
          fontSize: SizeConfig.font(1.8),
        ),
        prefixIcon: icon != null ? Icon(icon, color: colors.onSurface) : null,
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeConfig.wp(3)),
          borderSide: BorderSide(
            color: colors.outlineVariant,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeConfig.wp(3)),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
      ),
    );
  }
}
