import 'package:flutter/material.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
class CoachFocusTrendScreen extends StatefulWidget {
  final String userId;
  final String username;

  const CoachFocusTrendScreen({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  State<CoachFocusTrendScreen> createState() => _CoachFocusTrendScreenState();
}

class _CoachFocusTrendScreenState extends State<CoachFocusTrendScreen> {
  int _days = 7;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoachProvider>().fetchUserFocusHistory(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coachProvider = context.watch<CoachProvider>();
    final textColor = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("${widget.username}'s Focus Trend"),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Pixel.chevronleft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: coachProvider.progressHistoryLoading
          ? const Center(child: CircularProgressIndicator())
          : coachProvider.userProgressHistory.isEmpty
              ? Center(
                  child: Text(
                    'No focus history found for this user.',
                    style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildRangeSelector(theme),
                    const SizedBox(height: 12),
                    _buildFocusTrendChart(theme, coachProvider.userProgressHistory, _days),
                    const SizedBox(height: 24),
                    Text(
                      'Full History',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...coachProvider.userProgressHistory.map(
                      (p) => _buildProgressCard(theme, p),
                    ),
                  ],
                ),
    );
  }

  Widget _buildProgressCard(ThemeData theme, DailyProgressModel progress) {
    // Format minutes to hours/minutes
    final hours = progress.focusedMinutes ~/ 60;
    final minutes = progress.focusedMinutes % 60;
    String focusTime = '';
    if (hours > 0) {
      focusTime += '${hours}h ';
    }
    if (minutes > 0 || hours == 0) {
      focusTime += '${minutes}m';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: StyledCard(
        padding: EdgeInsets.zero,
        child: ListTile(
          leading: Icon(Pixel.calendar, size: 32, color: theme.colorScheme.onSurface),
          title: Text(
            progress.date, 
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Total Focus: $focusTime',
            style: TextStyle(color: theme.textTheme.bodyMedium?.color),
          ),
        ),
      ),
    );
  }

  Widget _buildFocusTrendChart(
    ThemeData theme,
    List<DailyProgressModel> history,
    int days,
  ) {
    final sorted = List.of(history)..sort((a, b) => a.date.compareTo(b.date));
    final sliced = sorted.length > days
        ? sorted.sublist(sorted.length - days)
        : sorted;

    final spots = <FlSpot>[];
    for (int i = 0; i < sliced.length; i++) {
      double minutes = 0;
      try {
        minutes = double.parse(sliced[i].focusedMinutes.toString());
      } catch (_) {}
      spots.add(FlSpot(i.toDouble(), minutes));
    }

    double maxY = spots.isNotEmpty
        ? spots.map((s) => s.y).reduce((a, b) => a > b ? a : b)
        : 60;
    if (maxY < 60) maxY = 60;

    String formatDate(String iso) {
      try {
        final d = DateTime.parse(iso);
        return "${d.day} ${_monthShort(d.month)}";
      } catch (e) {
        return "";
      }
    }

    final textColor = theme.colorScheme.onSurface;

    // Dynamic interval: max ~5 labels
    final bottomLabelInterval = (sliced.length / 5).ceilToDouble();

    // Auto font size: smaller for more days
    double fontSize = 12; // default
    if (sliced.length > 20) {
      fontSize = 8;
    } else if (sliced.length > 10) {
      fontSize = 10;
    }

    return StyledCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Focus Trend (minutes)",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY * 1.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    barWidth: 3,
                    color: theme.colorScheme.primary,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: theme.colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                ],
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: bottomLabelInterval,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= sliced.length)
                          return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Transform.rotate(
                            angle: -0.5,
                            child: Text(
                              formatDate(sliced[index].date),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: fontSize,
                                color: textColor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value == meta.max) return const SizedBox.shrink();
                        return Text(
                          '${value.toInt()}m',
                          style: theme.textTheme.bodySmall?.copyWith(color: textColor),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  verticalInterval: bottomLabelInterval,
                  horizontalInterval: 30,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: theme.dividerColor.withOpacity(0.3),
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: theme.dividerColor.withOpacity(0.3),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _monthShort(int m) {
    const names = ["", "Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    return names[m];
  }

  Widget _buildRangeSelector(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _rangeButton(theme, 7, "7D", isDark),
        const SizedBox(width: 8),
        _rangeButton(theme, 14, "14D", isDark),
        const SizedBox(width: 8),
        _rangeButton(theme, 30, "30D", isDark),
      ],
    );
  }

  Widget _rangeButton(ThemeData theme, int value, String label, bool isDark) {
    final isSelected = _days == value;
    final color = theme.colorScheme.primary;

    return GestureDetector(
      onTap: () => setState(() => _days = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? color : (isDark ? theme.cardColor : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? null : Border.all(color: theme.dividerColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : (isDark ? Colors.white : Colors.black),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}