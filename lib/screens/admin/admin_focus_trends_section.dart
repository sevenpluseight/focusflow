import 'package:flutter/material.dart';
import 'package:focusflow/providers/admin_stats_provider.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';

class FocusTrendsSection extends StatelessWidget {
  const FocusTrendsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AdminStatsProvider>(
      builder: (context, statsProvider, child) {
        if (statsProvider.isLoading) {
          return const StyledCard(
            title: 'Focus Trends',
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return StyledCard(
          title: 'Focus Trends',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow(
                context: context,
                icon: Pixel.clock,
                text:
                    'Total Focus Today: ${statsProvider.totalFocusTodayHours} hrs',
              ),
              const SizedBox(height: 8),
              _buildStatRow(
                context: context,
                icon: Pixel.calendar,
                text:
                    'Total Focus (7 Days): ${statsProvider.totalFocusThisWeekHours} hrs',
              ),
            ],
          ),
        );
      },
    );
  }

  // Copied this helper from your AdminDashboardScreen
  Widget _buildStatRow({
    required BuildContext context,
    required IconData icon,
    required String text,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.textTheme.bodyMedium?.color),
        const SizedBox(width: 8),
        Text(text, style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
      ],
    );
  }
}
