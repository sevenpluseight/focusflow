import 'package:flutter/material.dart';
import 'package:focusflow/providers/providers.dart'; // Ensure AdminAnalyticsProvider is exported here
import 'package:focusflow/widgets/widgets.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminAnalyticsProvider>().fetchAllAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                      child: Text('Error: ${statsProvider.errorMessage}'),
                    );
                  }

                  return StyledCard(
                    title: 'System Stats',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatRow(
                          context,
                          Pixel.users,
                          'Total Users: ${statsProvider.totalUsers}',
                        ),
                        const SizedBox(height: 8),
                        _buildStatRow(
                          context,
                          Pixel.contactmultiple,
                          'Active Coaches: ${statsProvider.activeCoaches}',
                        ),
                        const SizedBox(height: 8),
                        _buildStatRow(
                          context,
                          Pixel.chartmultiple,
                          'Active Users: ${statsProvider.activeUsers}',
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              Consumer<AdminAnalyticsProvider>(
                builder: (context, analyticsProvider, child) {
                  if (analyticsProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return Column(
                    children: [
                      StyledCard(
                        title: 'Focus Trends',
                        child: Column(
                          children: [
                            _buildStatRow(
                              context,
                              Pixel.clock,
                              'Total Focus Today: ${analyticsProvider.todayFocusHours} hrs',
                            ),
                            const SizedBox(height: 8),
                            _buildStatRow(
                              context,
                              Pixel.calendar,
                              'Total Focus (7 Days): ${analyticsProvider.last7DaysFocusHours} hrs',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      StyledCard(
                        title: 'Common Distractions',
                        child:
                            analyticsProvider.topDistractionsFormatted.isEmpty
                            ? const Text("No distraction data yet.")
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: analyticsProvider
                                    .topDistractionsFormatted
                                    .map((d) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8.0,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.circle,
                                              size: 8,
                                              color: theme
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color,
                                            ), // Bullet
                                            const SizedBox(width: 10),
                                            Text(
                                              "${d['name']} (${d['percentage']})",
                                              style: theme.textTheme.bodyLarge,
                                            ),
                                          ],
                                        ),
                                      );
                                    })
                                    .toList(),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, IconData icon, String text) {
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
