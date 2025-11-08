/* TODO - Comment out or remove debug printing */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/providers/providers.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final progressProvider = context.read<ProgressProvider>();

      final uid = authProvider.userModel?.uid;
      final dailyTarget = authProvider.userModel?.dailyTargetHours ?? 2.0;

      // Debug printing start
      print("[UserHomeScreen] Init: UID=$uid, dailyTarget=$dailyTarget");
      // Debug printing end

      if (uid != null) {
        progressProvider.listenTodayProgress(uid, dailyTarget);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final username = authProvider.userModel?.username ?? "User";
    final dailyTarget = authProvider.userModel?.dailyTargetHours ?? 2.0;

    final theme = Theme.of(context);
    final backgroundColor = theme.scaffoldBackgroundColor;
    final cardBackgroundColor = theme.colorScheme.surface;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Circular progress indicator
            Center(
              child: Consumer<ProgressProvider>(
                builder: (context, progress, _) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 260,
                            height: 260,
                            child: CircularProgressIndicator(
                              value: progress.todayProgress.clamp(0.0, 1.0),
                              strokeWidth: 16,
                              backgroundColor: Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey.shade300
                                  : Theme.of(context).colorScheme.surfaceContainerHighest,
                              valueColor: const AlwaysStoppedAnimation(
                                  Color(0xFFBFFB4F)),
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Text(
                            progress.getFormattedProgress(dailyTarget),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Today\'s Progress: ${(progress.todayProgress * 100).toStringAsFixed(0)}%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(),
                          height: 1.4,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Greeting and tip
            Padding(
              padding: const EdgeInsets.fromLTRB(17, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good Morning, $username!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: cardBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Productivity Tip: Placeholder!',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color
                            ?.withValues(),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
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
