import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/providers/providers.dart';
import 'other/productivity_tips.dart';

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

    _dailyTip = _computeTipForToday();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      final dailyTarget = userProvider.user?.dailyTargetHours ?? 2.0;
      _targetController.text = dailyTarget.toStringAsFixed(0);

      // Schedule tip update at 4AM
      _scheduleTipUpdate();
    });
  }

  @override
  void dispose() {
    _targetController.dispose();
    _tipTimer?.cancel();
    super.dispose();
  }

  // Picks a tip based on the date (after 4AM)
  String _computeTipForToday() {
    final now = DateTime.now();
    DateTime tipDate = now;
    if (now.hour < 4) {
      // Before 4AM, consider it "previous day"
      tipDate = now.subtract(const Duration(days: 1));
    }
    final daySeed = tipDate.year * 10000 + tipDate.month * 100 + tipDate.day;
    final random = Random(daySeed);
    return productivityTips[random.nextInt(productivityTips.length)];
  }

  // Schedule tip update at next 4AM
  void _scheduleTipUpdate() {
    final now = DateTime.now();
    DateTime next4AM = DateTime(now.year, now.month, now.day, 4);
    if (now.isAfter(next4AM)) {
      next4AM = next4AM.add(const Duration(days: 1));
    }

    final durationUntilNext4AM = next4AM.difference(now);

    _tipTimer = Timer(durationUntilNext4AM, () {
      setState(() {
        _dailyTip = _computeTipForToday();
      });

      // Schedule subsequent days every 24 hours
      _tipTimer = Timer.periodic(const Duration(days: 1), (_) {
        setState(() {
          _dailyTip = _computeTipForToday();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final progressProvider = context.watch<ProgressProvider>();

    final username = userProvider.user?.username ?? "User";
    final dailyTarget = userProvider.user?.dailyTargetHours ?? 2.0;

    final theme = Theme.of(context);
    final tipBoxColor = theme.brightness == Brightness.light
        ? const Color(0xFFE8F5E9)
        : theme.colorScheme.surface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 260,
                        height: 260,
                        child: CircularProgressIndicator(
                          value: progressProvider.todayProgress.clamp(0.0, 1.0),
                          strokeWidth: 16,
                          backgroundColor: theme.brightness == Brightness.light
                              ? Colors.grey.shade300
                              : theme.colorScheme.surfaceContainerHighest,
                          valueColor: const AlwaysStoppedAnimation(
                            Color(0xFFBFFB4F),
                          ),
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
                  const SizedBox(height: 20),
                  Text(
                    'Today\'s Progress: ${(progressProvider.todayProgress * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withValues(
                        alpha: 0.8,
                      ),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 30),
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
                      textAlign: TextAlign.center,
                      onSubmitted: (value) async {
                        final newValue = double.tryParse(value);
                        if (newValue == null || newValue < 1 || newValue > 8) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Enter a number between 1 and 8"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          _targetController.text = dailyTarget.toStringAsFixed(
                            0,
                          );
                          return;
                        }

                        final uid = userProvider.user?.uid;
                        if (uid != null) {
                          await userProvider.updateSettings(
                            dailyTargetHours: newValue,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Daily target updated ✅"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
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
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: tipBoxColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _dailyTip,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.9,
                        ),
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
