import 'package:flutter/material.dart';
import 'package:focusflow/models/challenge_model.dart';
import 'package:focusflow/providers/challenge_provider.dart';
import 'package:focusflow/providers/notification_provider.dart'; // For filter enum
import 'package:focusflow/widgets/widgets.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AdminApprovedChallengesScreen extends StatefulWidget {
  const AdminApprovedChallengesScreen({super.key});

  @override
  State<AdminApprovedChallengesScreen> createState() =>
      _AdminApprovedChallengesScreenState();
}

class _AdminApprovedChallengesScreenState
    extends State<AdminApprovedChallengesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  NotificationFilter _timeFilter = NotificationFilter.all; // Local time filter

  List<ChallengeModel> _filterChallenges(
    List<ChallengeModel> list,
    NotificationFilter timeFilter,
    String searchQuery,
  ) {
    final now = DateTime.now();
    List<ChallengeModel> timeFilteredList;

    // 1. Filter by TIME
    switch (timeFilter) {
      case NotificationFilter.week:
        final sevenDaysAgo = now.subtract(const Duration(days: 7));
        timeFilteredList = list
            .where((n) => n.createdAt.toDate().isAfter(sevenDaysAgo))
            .toList();
        break;
      case NotificationFilter.month:
        timeFilteredList = list
            .where(
              (n) =>
                  n.createdAt.toDate().year == now.year &&
                  n.createdAt.toDate().month == now.month,
            )
            .toList();
        break;
      case NotificationFilter.year:
        timeFilteredList = list
            .where((n) => n.createdAt.toDate().year == now.year)
            .toList();
        break;
      case NotificationFilter.all:
      default:
        timeFilteredList = list;
    }

    // 2. Filter by SEARCH
    if (searchQuery.isEmpty) {
      return timeFilteredList;
    }
    return timeFilteredList
        .where((c) => c.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ChallengeProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('All Challenges'),
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
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Search by challenge name...',
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
                const SizedBox(height: 16),
                // --- Time Filter ---
                Row(
                  children: [
                    Text(
                      'Filter by: ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<NotificationFilter>(
                      value: _timeFilter,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      iconEnabledColor: theme.colorScheme.onSurface.withOpacity(
                        0.7,
                      ),
                      dropdownColor: theme.cardColor,
                      underline: Container(height: 0),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _timeFilter = value;
                          });
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: NotificationFilter.all,
                          child: Text('All Time'),
                        ),
                        DropdownMenuItem(
                          value: NotificationFilter.week,
                          child: Text('This Week'),
                        ),
                        DropdownMenuItem(
                          value: NotificationFilter.month,
                          child: Text('This Month'),
                        ),
                        DropdownMenuItem(
                          value: NotificationFilter.year,
                          child: Text('This Year'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ChallengeModel>>(
              stream: provider.getApprovedChallengesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No approved challenges.'));
                }

                // Apply both filters
                final filteredList = _filterChallenges(
                  snapshot.data!,
                  _timeFilter,
                  _searchQuery,
                );

                if (filteredList.isEmpty) {
                  return const Center(
                    child: Text('No challenges match filter.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final challenge = filteredList[index];
                    return _buildApprovedChallengeCard(
                      challenge,
                      theme,
                      context,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovedChallengeCard(
    ChallengeModel challenge,
    ThemeData theme,
    BuildContext context,
  ) {
    final dateFormat = DateFormat('MMM dd');
    final startDate = dateFormat.format(challenge.startDate!.toDate());
    final endDate = dateFormat.format(challenge.endDate!.toDate());
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: StyledCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              challenge.name,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatColumn(
                  theme,
                  Pixel.clock,
                  'Goal',
                  '${challenge.focusGoalHours} hrs',
                ),
                const SizedBox(height: 8),
                _buildStatColumn(theme, Pixel.calendar, 'Starts', startDate),
                const SizedBox(height: 8),
                _buildStatColumn(theme, Pixel.calendar, 'Ends', endDate),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 20, color: isDark ? Colors.white54 : Colors.black45),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),
        const SizedBox(width: 12),
        const SizedBox(height: 12),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
