import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:focusflow/widgets/widgets.dart'; // For StyledCard

class AdminDistractionChart extends StatelessWidget {
  final Map<String, int> stats;

  const AdminDistractionChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (stats.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text("No distraction data")),
      );
    }

    final total = stats.values.fold(0, (sum, count) => sum + count);

    int colorIndex = 0;
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    final sections = stats.entries.map((entry) {
      final isLarge = entry.value / total > 0.15;
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: isLarge ? "${entry.key}\n${entry.value}" : "",
        radius: isLarge ? 60 : 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return StyledCard(
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: stats.entries.toList().asMap().entries.map((e) {
              final index = e.key;
              final entry = e.value;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    color: colors[index % colors.length],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${entry.key} (${entry.value})",
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
