import 'package:flutter/material.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/screens/coach/coach.dart';

class CoachReportSummaryScreen extends StatelessWidget {
  const CoachReportSummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coachProvider = context.watch<CoachProvider>();
    final List<UserModel> users = coachProvider.connectedUsers;

    // --- Calculate Stats ---
    final totalUsers = users.length;
    final atRiskUsers = users.where((u) => (u.currentStreak ?? 0) == 0).toList();
    
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

            // 1. "Quick Stats" Title
            const Text(
              'Quick Stats',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 2. "Quick Stats" Card (no title inside)
            StyledCard(
              child: Column(
                children: [
                  _buildStatItem(theme, Pixel.users, 'Total Users', '$totalUsers'),
                  _buildStatItem(theme, Pixel.trending, 'Average Streak', '${avgStreak.toStringAsFixed(1)} days'),
                ],
              ),
            ),
            // -----------------------

            const SizedBox(height: 24),

            // --- At-Risk Users Card ---
            const Text(
              'At-Risk Users',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            StyledCard(
              child: atRiskUsers.isEmpty
                  ? Text(
                      'Great job! No users are currently at risk.',
                      style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                    )
                  : Column(
                      children: atRiskUsers.map((user) {
                        return _buildAtRiskUserTile(context, theme, user);
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for the stat items
  Widget _buildStatItem(ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.onSurface, size: 24),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Helper for the "At-Risk Users" list
  Widget _buildAtRiskUserTile(BuildContext context, ThemeData theme, UserModel user) {
    return ListTile(
      leading: Icon(Pixel.user, color: theme.colorScheme.tertiary),
      title: Text(user.username, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('Streak: 0 days', style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
      trailing: Icon(Pixel.chevronright, color: theme.textTheme.bodyMedium?.color),
      onTap: () {
        // Navigate to the user's report screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CoachUserReportScreen(
              userId: user.uid,
            ),
          ),
        );
      },
    );
  }
}