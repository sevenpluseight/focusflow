import 'package:flutter/material.dart';
// import 'package:pixelarticons/pixelarticons.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    // final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildDashboardCard(
              context: context,
              title: 'System Stats',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Total Users: 150', style: textTheme.bodyLarge?.copyWith(height: 1.5)),
                  Text('• Active Coaches: 12', style: textTheme.bodyLarge?.copyWith(height: 1.5)),
                  Text('• Daily Engagement: 65%', style: textTheme.bodyLarge?.copyWith(height: 1.5)),
                ],
              ),
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
                  Text('1. Social Media (35%)', style: textTheme.bodyLarge?.copyWith(height: 1.5)),
                  Text('2. Environment Noise (22%)', style: textTheme.bodyLarge?.copyWith(height: 1.5)),
                  Text('3. Messaging Apps (18%)', style: textTheme.bodyLarge?.copyWith(height: 1.5)),
                ],
              ),
            ),
          ],
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
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
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
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}