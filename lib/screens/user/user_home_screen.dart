import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/services/services.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final TextEditingController _targetController = TextEditingController();
  late String _dailyTip;
  Timer? _tipTimer;

  @override
  void initState() {
    super.initState();

    _dailyTip = ProductivityService.getDailyTip();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      final dailyTarget = userProvider.user?.dailyTargetHours ?? 2.0;
      _targetController.text = dailyTarget.toStringAsFixed(0);

      _scheduleTipUpdate();
    });
  }

  @override
  void dispose() {
    _targetController.dispose();
    _tipTimer?.cancel();
    super.dispose();
  }

  void _scheduleTipUpdate() {
    _tipTimer = Timer(ProductivityService.durationUntilNext4AM(), () {
      setState(() => _dailyTip = ProductivityService.getDailyTip());

      _tipTimer = Timer.periodic(const Duration(days: 1), (_) {
        setState(() => _dailyTip = ProductivityService.getDailyTip());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final progressProvider = context.watch<ProgressProvider>();

    final username = userProvider.user?.username ?? "User";
    final dailyTarget = userProvider.user?.dailyTargetHours ?? 2.0;
    final completedMinutes = (progressProvider.todayProgress * dailyTarget * 60).round();

    final theme = Theme.of(context);
    final progress = progressProvider.todayProgress.clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 120),

                  // Circular progress
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 280,
                        height: 280,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 18,
                          backgroundColor: theme.brightness == Brightness.light
                              ? theme.colorScheme.primary.withOpacity(0.2)
                              : theme.colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Text(
                        progressProvider.getFormattedProgress(dailyTarget),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 60),
                  Text(
                    'Today\'s Progress: $completedMinutes min / ${dailyTarget.toStringAsFixed(0)} hrs',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),

                  // Motivational message
                  Text(
                    "Every minute counts! Stay focused 💪",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.brightness == Brightness.light
                          ? Colors.black.withOpacity(0.7)
                          : Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /*
                  // Daily Target Hours input (commented)
                  SizedBox(
                    width: 150,
                    child: TextField(
                      controller: _targetController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Daily Target Hours',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onSubmitted: (value) async {
                        final newValue = double.tryParse(value);
                        if (newValue == null || newValue < 1 || newValue > 8) {
                          // Show error
                          _targetController.text = dailyTarget.toStringAsFixed(0);
                          return;
                        }
                        final uid = userProvider.user?.uid;
                        if (uid != null) {
                          await userProvider.updateSettings(dailyTargetHours: newValue);
                        }
                      },
                    ),
                  ),
                  */
                ],
              ),
            ),

            // Top greeting & daily tip
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
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      
                    ),
                    child: Text(
                      _dailyTip,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.9),
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
