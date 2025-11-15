import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/screens/core/main_navigation_controller.dart';
import 'package:focusflow/screens/user/coach_application_screen.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:focusflow/screens/auth/auth.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  void _switchToCoachMode(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MainNavigationController(
          currentUserRole: UserRole.coach,
        ),
      ),
    );
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Confirm Logout',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 16,
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              child: Text(
                'Logout',
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true && context.mounted) {
      await authProvider.signOut();
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    final String actualRole = user?.role ?? 'user';
    final bool isCoachInUserMode = (actualRole == 'coach');

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final cardColor = !isDark ? const Color(0xFFE8F5E9) : theme.colorScheme.surfaceVariant;

    if (user == null && !userProvider.isLoading) {
      Future.microtask(() => userProvider.fetchUser());
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: userProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Username + Focused time
                    StyledCard(
                      color: cardColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            user?.username ?? "User",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            "-- hrs",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Streaks card + Longest streak
                    StyledCard(
                      color: cardColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Current Streak",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${user?.currentStreak ?? 0} days",
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Longest Streak",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${user?.longestStreak ?? 0} days",
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Active challenge card 
                    StyledCard(
                      color: cardColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Active Challenge",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (isCoachInUserMode)
                      ElevatedButton.icon(
                        icon: const Icon(Pixel.repeat),
                        label: const Text("Switch to Coach Mode"),
                        onPressed: () => _switchToCoachMode(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightGreenAccent,
                        ),
                      )
                    else
                      PrimaryButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CoachApplicationScreen(),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Pixel.plus),
                            SizedBox(width: 8),
                            Text("Request to be Coach"),
                          ],
                        ),
                      ),
                    const SizedBox(height: 32),

                    // Settings 
                    Text(
                      "Settings",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Reusable components test - uncomment if want to test
                    /*
                    StyledCard(
                      color: cardColor,
                      title: "Reusable Components Test",
                      child: ListTile(
                        leading: const Icon(Pixel.warningbox),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ReusableComponentsTestScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    */

                    // Theme Preferences
                    StyledCard(
                      color: cardColor,
                      child: ListTile(
                        leading: const Icon(Pixel.sunalt),
                        title: const Text("Theme Preferences"),
                        onTap: () => context.read<ThemeProvider>().toggleTheme(),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Log Out
                    StyledCard(
                      color: cardColor,
                      child: ListTile(
                        leading: const Icon(Pixel.logout),
                        title: const Text("Log Out"),
                        onTap: () => _showLogoutConfirmation(context),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
