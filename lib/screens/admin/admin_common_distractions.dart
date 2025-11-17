import 'package:flutter/material.dart';
import 'package:focusflow/providers/admin_stats_provider.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:provider/provider.dart';

class CommonDistractionsSection extends StatelessWidget {
  const CommonDistractionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Consumer<AdminStatsProvider>(
      builder: (context, statsProvider, child) {
        if (statsProvider.isLoading) {
          return const StyledCard(
            title: 'Common Distractions',
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final distractions = statsProvider.topDistractions;
        if (distractions.isEmpty) {
          return const StyledCard(
            title: 'Common Distractions',
            child: Center(child: Text('No distraction data found.')),
          );
        }

        return StyledCard(
          title: 'Common Distractions (Last 100 Logs)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: distractions.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final category = entry.value.key;
              final count = entry.value.value;

              return Text(
                '$index. $category ($count logs)',
                style: textTheme.bodyLarge?.copyWith(height: 1.5),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
