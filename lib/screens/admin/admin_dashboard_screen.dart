import 'package:flutter/material.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<AdminStatsProvider>(
                builder: (context, statsProvider, child) {
                  if (statsProvider.isLoading &&
                      statsProvider.userCounts.isEmpty) {
                    return _buildDashboardCard(
                      context: context,
                      title: 'System Stats',
                      content: const Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (statsProvider.hasError) {
                    return _buildDashboardCard(
                      context: context,
                      title: 'System Stats',
                      content: Text(
                        'Error loading stats: ${statsProvider.errorMessage}',
                      ),
                    );
                  }
                  final totalUsers = statsProvider.totalUsers;
                  final activeCoaches = statsProvider.activeCoaches;
                  return _buildDashboardCard(
                    context: context,
                    title: 'System Stats',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatRow(
                          context: context,
                          icon: Pixel.users,
                          text: 'Total Users: $totalUsers',
                        ),
                        const SizedBox(height: 8),
                        _buildStatRow(
                          context: context,
                          icon: Pixel.contactmultiple,
                          text: 'Active Coaches: $activeCoaches',
                        ),
                        const SizedBox(height: 8),
                        _buildStatRow(
                          context: context,
                          icon: Pixel.chartmultiple,
                          text: 'Daily Engagement: 65%',
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildDashboardCard(
                context: context,
                title: 'Focus Trends',
                content: Container(
                  height: 150,
                  alignment: Alignment.center,
                  child: Text(
                    '[Placeholder for Focus Trend Chart]',
                    style: textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildDashboardCard(
                context: context,
                title: 'Common Distractions',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1. Social Media (35%)',
                      style: textTheme.bodyLarge?.copyWith(height: 1.5),
                    ),
                    Text(
                      '2. Environment Noise (22%)',
                      style: textTheme.bodyLarge?.copyWith(height: 1.5),
                    ),
                    Text(
                      '3. Messaging Apps (18%)',
                      style: textTheme.bodyLarge?.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build consistent cards
  Widget _buildDashboardCard({
    required BuildContext context,
    required String title,
    required Widget content,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required BuildContext context,
    required IconData icon,
    required String text,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, size: 20, color: theme.textTheme.bodyMedium?.color),
        const SizedBox(width: 8),
        Text(text, style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
      ],
    );
  }
}
