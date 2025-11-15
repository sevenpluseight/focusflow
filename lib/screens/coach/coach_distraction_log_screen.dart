import 'package:flutter/material.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart'; 
import 'package:focusflow/widgets/widgets.dart';

class CoachDistractionLogScreen extends StatefulWidget {
  final String userId;
  final String username;

  const CoachDistractionLogScreen({
    Key? key,
    required this.userId,
    required this.username,
  }) : super(key: key);

  @override
  State<CoachDistractionLogScreen> createState() => _CoachDistractionLogScreenState();
}

class _CoachDistractionLogScreenState extends State<CoachDistractionLogScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoachProvider>().fetchDistractionLogs(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final isDark = theme.brightness == Brightness.dark;
    final coachProvider = context.watch<CoachProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("${widget.username}'s Logs"),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Pixel.chevronleft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: coachProvider.logsLoading
          ? const Center(child: CircularProgressIndicator())
          : coachProvider.userLogs.isEmpty
              ? Center(
                  child: Text(
                    'No distraction logs found for this user.',
                    style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: coachProvider.userLogs.length,
                  itemBuilder: (context, index) {
                    final log = coachProvider.userLogs[index];
                    return _buildLogCard(theme, log);
                  },
                ),
    );
  }

  Widget _buildLogCard(ThemeData theme, DistractionLogModel log) {
    final date = log.createdAt.toDate();
    final formattedDate = '${date.month}/${date.day}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: StyledCard(
        title: 'Category: ${log.category}',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (log.note != null && log.note!.isNotEmpty)
                    Text(
                      'Note: ${log.note}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Pixel.flag, size: 18),
                    label: const Text('Report'),
                    onPressed: () {
                      _showReportConfirmation(context, log);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: log.imageUrl != null
                  ? Image.network(log.imageUrl!, fit: BoxFit.cover)
                  : Icon(Pixel.image, color: Colors.grey.shade400, size: 40),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showReportConfirmation(BuildContext context, DistractionLogModel log) async {
    final coachProvider = context.read<CoachProvider>();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bool? confirm = await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? theme.cardColor : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: isDark ? Colors.white70 : Colors.black54,
          fontSize: 16,
        ),
        title: const Text('Report Log?'),
        content: const Text('This will flag the log for admin review. Are you sure?'),
        actions: [
          TextButton(
            child: Text(
              'Cancel',
              // --- Optional: Style the cancel button too ---
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 16,
              ),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          TextButton(
            child: Text(
              'Report',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await coachProvider.reportLog(widget.userId, log.id);
        if (mounted) {
          CustomSnackBar.show(
            context,
            message: 'Log has been reported to admin.',
            type: SnackBarType.success,
          );
        }
      } catch (e) {
        if (mounted) {
          CustomSnackBar.show(
            context,
            message: e.toString(),
            type: SnackBarType.error,
          );
        }
      }
    }
  }
}