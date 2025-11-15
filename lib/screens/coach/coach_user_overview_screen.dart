import 'package:flutter/material.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';

class CoachUserOverviewScreen extends StatelessWidget {
  final String userId;

  const CoachUserOverviewScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get the specific user from the provider
    UserModel? user;
    try {
      user = context.read<CoachProvider>().connectedUsers.firstWhere(
        (u) => u.uid == userId,
      );
    } catch (e) {
      user = null;
    }

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('User not found.')),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(user.username),
        backgroundColor: isDark ? const Color(0xFF3A3D42) : const Color(0xFFE8F5E9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Pixel.chevronleft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatCard(
              theme: theme,
              title: 'User Details',
              items: [
                _buildStatItem(theme, Pixel.mail, 'Email', user.email),
                _buildStatItem(theme, Pixel.user, 'Role', user.role),
                _buildStatItem(theme, Pixel.briefcasecheck, 'Sign-in Method', user.signInMethod),
              ],
            ),
            const SizedBox(height: 20),
            _buildStatCard(
              theme: theme,
              title: 'Focus Preferences',
              items: [
                _buildStatItem(theme, Pixel.bullseyearrow, 'Daily Target', '${user.dailyTargetHours ?? 2} hours'),
                _buildStatItem(theme, Pixel.briefcasesearch1, 'Work Interval', '${user.workInterval ?? 25} min'),
                _buildStatItem(theme, Pixel.coffee, 'Break Interval', '${user.breakInterval ?? 5} min'),
                _buildStatItem(theme, Pixel.archive, 'Focus Type', user.focusType ?? 'Classic'),
              ],
            ),
            const SizedBox(height: 20),
            _buildStatCard(
              theme: theme,
              title: 'Streak',
              items: [
                _buildStatItem(theme, Pixel.trendingup, 'Current Streak', '${user.currentStreak ?? 0} days'),
                _buildStatItem(theme, Pixel.trophy, 'Longest Streak', '${user.longestStreak ?? 0} days'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper for the stat cards
  Widget _buildStatCard({required ThemeData theme, required String title, required List<Widget> items}) {
    return StyledCard(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }

  // Helper for the individual stat rows
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
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}