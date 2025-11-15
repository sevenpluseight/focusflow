import 'package:flutter/material.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';

class CoachFocusTrendScreen extends StatefulWidget {
  final String userId;
  final String username;

  const CoachFocusTrendScreen({
    Key? key,
    required this.userId,
    required this.username,
  }) : super(key: key);

  @override
  State<CoachFocusTrendScreen> createState() => _CoachFocusTrendScreenState();
}

class _CoachFocusTrendScreenState extends State<CoachFocusTrendScreen> {
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
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: coachProvider.userProgressHistory.length,
                  itemBuilder: (context, index) {
                    final progress = coachProvider.userProgressHistory[index];
                    return _buildProgressCard(theme, progress);
                  },
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
            progress.date, // This is the date string, e.g., "2025-11-14"
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
}