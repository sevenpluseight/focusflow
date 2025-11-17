import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/screens/core/main_navigation_controller.dart';
import 'package:focusflow/screens/user/coach_application_screen.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:focusflow/screens/auth/auth.dart';
import 'package:intl/intl.dart';
import 'package:focusflow/screens/user/user.dart';
// import 'reusable_components_test_screen.dart';

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

    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const ConfirmationDialog(
          title: 'Confirm Logout',
          contentText: 'Are you sure you want to log out?',
          confirmText: 'Logout',
        );
      },
    );

    if (confirmLogout == true && context.mounted) {
      await authProvider.signOut(context);
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
    final challengeProvider = context.watch<ChallengeProvider>();

    final String actualRole = user?.role ?? 'user';
    final bool isCoachInUserMode = (actualRole == 'coach');

    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    final joinedChallenges = challengeProvider.approvedChallenges
        .where((challenge) => challenge.participants.contains(user?.uid))
        .toList();
    // final cardColor = theme.cardColor;

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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            user?.username ?? "User",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "-- hrs",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Streaks card + Longest streak
                    StyledCard(
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
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${user?.currentStreak ?? 0} days",
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: theme.colorScheme.primary, // Theme-adaptive
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
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${user?.longestStreak ?? 0} days",
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    const SizedBox(height: 16),

                    // Joined Challenges
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Joined Challenges",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UserJoinedChallengesScreen(),
                              ),
                            );
                          },
                          child: const StyledCard(
                            child: Text(
                              "Joined Challenges",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (isCoachInUserMode)
                      PrimaryButton(
                        onPressed: () => _switchToCoachMode(context),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Pixel.repeat),
                            SizedBox(width: 8),
                            Text("Switch to Coach Mode"),
                          ],
                        ),
                      )
                    else
                      PrimaryButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CoachApplicationScreen(),
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
                    const SizedBox(height: 30),

                    // Settings 
                    Text(
                      "Settings",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Reusable components test
                    // SecondaryButton(
                    //   onPressed: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => const ReusableComponentsTestScreen(),
                    //       ),
                    //     );
                    //   },
                    //   child: const Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       Icon(Pixel.humanhandsup),
                    //       SizedBox(width: 8),
                    //       Text('Open Test Screen'),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(height: 17),
                    
                    // Theme Preferences
                    SecondaryButton(
                      onPressed: () => context.read<ThemeProvider>().toggleTheme(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(theme.brightness == Brightness.dark ? Pixel.sunalt : Pixel.moon),
                          const SizedBox(width: 8),
                          const Text('Theme Preferences'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 17),

                    // Log Out
                    SecondaryButton(
                      onPressed: () => _showLogoutConfirmation(context),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Pixel.logout),
                          SizedBox(width: 8),
                          Text('Log Out'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }


}
