import 'package:flutter/material.dart';
import 'package:focusflow/models/coach_request_model.dart';
import 'package:focusflow/providers/coach_request_provider.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/screens/admin/admin.dart';

class AdminCoachRequestsScreen extends StatefulWidget {
  const AdminCoachRequestsScreen({super.key});

  @override
  State<AdminCoachRequestsScreen> createState() =>
      _AdminCoachRequestsScreenState();
}

class _AdminCoachRequestsScreenState extends State<AdminCoachRequestsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<CoachRequestProvider>();
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('All Coach Requests'),
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
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                labelText: 'Search by name or username...',
                prefixIcon: const Icon(Pixel.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Pixel.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              style: theme.textTheme.bodyLarge,
            ),
          ),
          Expanded(
            child: StreamBuilder<List<CoachRequestModel>>(
              stream: provider.getAllRequestsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Pixel.users,
                          size: 48,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                        const SizedBox(height: 16),
                        const Text('No requests found.'),
                      ],
                    ),
                  );
                }

                // Apply search filter
                final filteredList = snapshot.data!.where((request) {
                  final name = request.fullName.toLowerCase();
                  final username = request.username.toLowerCase();
                  return name.contains(_searchQuery) ||
                      username.contains(_searchQuery);
                }).toList();

                if (filteredList.isEmpty) {
                  return const Center(child: Text('No requests match search.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final request = filteredList[index];
                    return _buildRequestCard(request, theme, context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(
    CoachRequestModel request,
    ThemeData theme,
    BuildContext context,
  ) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final requestDate = dateFormat.format(request.createdAt.toDate());
    final isDark = theme.brightness == Brightness.dark;

    final Color statusBackgroundColor = theme.colorScheme.primary;
    final Color statusForegroundColor = Colors.white;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: StyledCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.fullName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request.username,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                // Show status
                Text(
                  request.status.toUpperCase(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: statusForegroundColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Pixel.calendar,
                  size: 16,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
                const SizedBox(width: 6),
                Text(
                  'Applied: $requestDate',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Pixel.bullseye,
                  size: 16,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    request.expertise,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 12),
                // Show View button only for pending requests
                if (request.status == 'pending')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PrimaryButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) =>
                                CoachRequestDetailsSheet(request: request),
                          );
                        },
                        // Style button to be small
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          textStyle: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('View Request'),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
