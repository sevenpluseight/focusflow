import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/widgets/widgets.dart';

class AdminFocusChart extends StatelessWidget {
  final List<DailyProgressModel> data;

  const AdminFocusChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (data.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text("No data available")),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i].focusedMinutes.toDouble()));
    }

    // Calculate max Y for better scaling
    double maxY = spots.map((e) => e.y).fold(0, (p, c) => p > c ? p : c);
    if (maxY == 0) maxY = 100;

    return StyledCard(
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
      child: SizedBox(
        height: 250,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value >= 1000
                          ? '${(value / 1000).toStringAsFixed(1)}k'
                          : value.toInt().toString(),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: (data.length / 5).ceilToDouble(),
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index >= 0 && index < data.length) {
                      try {
                        final date = DateTime.parse(data[index].date);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "${date.day}/${date.month}",
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      } catch (e) {
                        return const Text("");
                      }
                    }
                    return const Text("");
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            minX: 0,
            maxX: (data.length - 1).toDouble(),
            minY: 0,
            maxY: maxY * 1.1,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: theme.colorScheme.primary,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
