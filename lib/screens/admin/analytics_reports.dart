import 'package:flutter/material.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/screens/admin/admin.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
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
    final provider = context.watch<AdminAnalyticsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("System Analytics"),
        actions: [
          IconButton(
            icon: const Icon(Pixel.undo), // or Pixel.refresh
            onPressed: () => provider.fetchAllAnalytics(),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
          ? Center(child: Text(provider.errorMessage!))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  "Global Focus Minutes (Last 30 Days)",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                AdminFocusChart(data: provider.globalFocusHistory),

                const SizedBox(height: 32),

                Text(
                  "Distraction Breakdown",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                AdminDistractionChart(stats: provider.globalDistractionStats),
              ],
            ),
    );
  }
}
