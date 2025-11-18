import 'package:flutter/material.dart';
import 'package:focusflow/models/challenge_model.dart';
import 'package:focusflow/providers/challenge_provider.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/screens/admin/admin.dart';

class AdminPendingChallengesScreen extends StatefulWidget {
  const AdminPendingChallengesScreen({super.key});

  @override
  State<AdminPendingChallengesScreen> createState() =>
      _AdminPendingChallengesScreenState();
}

class _AdminPendingChallengesScreenState
    extends State<AdminPendingChallengesScreen> {
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
    final provider = context.watch<ChallengeProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Pending Challenges'),
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
          ),
          Expanded(
            child: StreamBuilder<List<ChallengeModel>>(
              // Use the dedicated pending stream
              stream: provider.getPendingChallengesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No pending requests.'));
                }

                // Apply search filter
                final filteredList = snapshot.data!.where((request) {
                  return request.name.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredList.isEmpty) {
                  return const Center(child: Text('No requests match search.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final request = filteredList[index];
                    return _buildChallengeRequestCard(request, theme, context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // This card is similar to the coach request card
  Widget _buildChallengeRequestCard(
    ChallengeModel request,
    ThemeData theme,
    BuildContext context,
  ) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final requestDate = dateFormat.format(request.createdAt.toDate());
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: StyledCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
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
                              request.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${request.focusGoalHours} Hour Goal',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                      const Spacer(),
                      PrimaryButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) =>
                                ChallengeRequestDetailsSheet(request: request),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
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
            ),
          ],
        ),
      ),
    );
  }
}
