import 'package:flutter/material.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

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
                    return const StyledCard(
                      title: 'System Stats',
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (statsProvider.hasError) {
                    return StyledCard(
                      title: 'System Stats',
                      child: Text(
                        'Error loading stats: ${statsProvider.errorMessage}',
                      ),
                    );
                  }
                  final totalUsers = statsProvider.totalUsers;
                  final activeCoaches = statsProvider.activeCoaches;
                  return StyledCard(
                    title: 'System Stats',
                    child: Column(
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
              StyledCard(
                title: 'Focus Trends',
                child: Container(
                  height: 150,
                  alignment: Alignment.center,
                  child: Text(
                    '[Placeholder for Focus Trend Chart]',
                    style: textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              StyledCard(
                title: 'Common Distractions',
                child: Column(
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

  Widget _buildStatRow({
    required BuildContext context,
    required IconData icon,
    required String text,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: theme.textTheme.bodyMedium?.color),
        const SizedBox(width: 8),
        Text(text, style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
      ],
    );
  }
}
