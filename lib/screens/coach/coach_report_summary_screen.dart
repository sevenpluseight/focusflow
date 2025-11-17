import 'package:flutter/material.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/screens/coach/coach_aggregate_stats_screen.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';

class CoachReportSummaryScreen extends StatelessWidget {
  const CoachReportSummaryScreen({super.key});

  // Helper for the stat items
  Widget _buildStatItem(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.onSurface, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coachProvider = context.watch<CoachProvider>();
    final List<UserModel> users = coachProvider.connectedUsers;
    final textColor = theme.colorScheme.onSurface;

    // --- Calculate Stats ---
    final totalUsers = users.length;
    double totalStreak = 0;
    for (var user in users) {
      totalStreak += (user.currentStreak ?? 0);
    }
    final avgStreak = (totalUsers > 0) ? (totalStreak / totalUsers) : 0.0;
    // -----------------------

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. "Quick Stats" Section
            Text(
              'Quick Stats',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),

            // 2. TAPPABLE "Quick Stats" Card
            InkWell(
              onTap: () {
                // Navigate to the new aggregate stats screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CoachAggregateStatsScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: StyledCard(
                child: coachProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          _buildStatItem(
                            theme,
                            Pixel.users,
                            'Total Users',
                            '$totalUsers',
                          ),
                          _buildStatItem(
                            theme,
                            Pixel.trending,
                            'Average Streak',
                            '${avgStreak.toStringAsFixed(1)} days',
                          ),
                          // Add a visual cue for tapping
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'View Aggregate Graph',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Pixel.chevronright,
                                  color: theme.colorScheme.primary,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // 3. AI System Strategy Section
            Text(
              'AI System Strategy',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            StyledCard(
              padding: const EdgeInsets.all(16),
              child: coachProvider.systemAiLoading
                  ? const Center(child: CircularProgressIndicator())
                  : InkWell(
                      onTap: coachProvider
                          .fetchSystemAiRecommendations, // Reloads on tap
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recommended Focus:',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            coachProvider.systemAiRecommendations,
                            style: theme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '(Tap to refresh strategy based on client average)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
