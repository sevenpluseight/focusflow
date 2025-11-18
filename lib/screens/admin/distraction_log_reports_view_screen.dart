import 'package:flutter/material.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:focusflow/screens/admin/admin.dart';

class AdminReportedLogsScreen extends StatefulWidget {
  const AdminReportedLogsScreen({super.key});

  @override
  State<AdminReportedLogsScreen> createState() =>
      _AdminReportedLogsScreenState();
}

class _AdminReportedLogsScreenState extends State<AdminReportedLogsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportDistractLogProvider>().fetchPendingReports();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ReportWithDetails> _filterReports(List<ReportWithDetails> list) {
    // Filter Removed. Only Search logic remains.
    if (_searchQuery.isEmpty) {
      return list;
    }

    final query = _searchQuery.toLowerCase();
    return list.where((item) {
      final usernameMatch = item.userUsername.toLowerCase().contains(query);
      final noteMatch = item.log.note?.toLowerCase().contains(query) ?? false;
      return usernameMatch || noteMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ReportDistractLogProvider>();
    final filteredList = _filterReports(provider.pendingReports);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Pending Reports'),
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(Pixel.chevronleft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.cardColor,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    labelText: 'Search user or note...',
                    prefixIcon: const Icon(Pixel.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Pixel.close),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                ),
                // Filter Row removed here
              ],
            ),
          ),

          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredList.isEmpty
                ? Center(
                    child: Text(
                      provider.pendingReports.isEmpty
                          ? 'No pending reports.'
                          : 'No matches found.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      return _buildReportCard(filteredList[index], theme);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(ReportWithDetails details, ThemeData theme) {
    final dateStr = DateFormat(
      'MMM dd, yyyy - HH:mm',
    ).format(details.report.createdAt.toDate());
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: StyledCard(
        title: "${details.userUsername}'s Distraction Log",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtitle Row
            Text(
              "Reported by: ${details.coachUsername}",
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              dateStr,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
            const SizedBox(height: 16),

            // Content Row
            Row(
              children: [
                // Left side: Info summary
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        Pixel.list,
                        "Category",
                        details.log.category,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Pixel.notes,
                        "Note",
                        (details.log.note == null || details.log.note!.isEmpty)
                            ? "No note provided"
                            : details.log.note!,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Right side: Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) =>
                            ReportDetailsSheet(details: details),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    child: const Text("Check Report"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              children: [
                TextSpan(
                  text: "$label: ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
