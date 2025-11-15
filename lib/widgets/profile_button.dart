import 'package:flutter/material.dart';
import 'package:focusflow/widgets/styled_card.dart';
import 'package:pixelarticons/pixelarticons.dart';

class ProfileButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showChevron;

  const ProfileButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.showChevron = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: StyledCard(
        child: Row(
          children: [
            Icon(
              icon,
              size: 28,
              color: theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (showChevron)
              Icon(Pixel.chevronright, color: theme.textTheme.bodyMedium?.color),
          ],
        ),
      ),
    );
  }
}
