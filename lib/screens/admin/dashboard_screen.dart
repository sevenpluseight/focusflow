import 'package:flutter/material.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/screens/admin/admin.dart';

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
                  final activeUsers = statsProvider.activeUsers;

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
                          text: 'Active Users: $activeUsers',
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // const FocusTrendsSection(),
              const SizedBox(height: 20),
              // const CommonDistractionsSection(),
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
