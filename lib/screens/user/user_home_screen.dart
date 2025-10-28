import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/providers/providers.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final username = authProvider.userModel?.username ?? "User";

    final theme = Theme.of(context);

    final backgroundColor = theme.scaffoldBackgroundColor;

    final cardBackgroundColor = theme.colorScheme.surface;
    final progressBackgroundColor = theme.colorScheme.surfaceVariant;

    return Container(
      color: backgroundColor,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Greeting
              Text(
                'Good Morning, $username!',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 16),

              // Productivity Tips Box
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Productivity Tip: Placeholder!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Circular Progress Indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: 0.75,
                      strokeWidth: 12,
                      backgroundColor: progressBackgroundColor,
                      valueColor:
                          const AlwaysStoppedAnimation(Color(0xFFBFFB4F)),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    '3 / 4 Hrs',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Today's progress text
              Text(
                'Today\'s Progress: 75%',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
