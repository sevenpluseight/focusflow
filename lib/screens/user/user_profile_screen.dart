import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:focusflow/providers/providers.dart';
import '../auth/auth.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

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
                style: TextStyle(
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

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final cardColor = !isDark ? const Color(0xFFE8F5E9) : theme.colorScheme.surfaceVariant;

    // Fetch user data if not loaded yet
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
                    // ------------------- Username + Focused Time -------------------
                    Card(
                      color: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
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
                    ),
                    const SizedBox(height: 16),

                    // ------------------- Streaks Card -------------------
                    Card(
                      color: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Current Streak",
                                  style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
                                ),
                                Text(
                                  "${user?.currentStreak ?? 0} days",
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Longest Streak",
                                  style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
                                ),
                                Text(
                                  "${user?.longestStreak ?? 0} days",
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ------------------- Active Challenge Card -------------------
                    Card(
                      color: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
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
                    ),
                    const SizedBox(height: 8),

                    // ------------------- Request to be Coach Button -------------------
                    ElevatedButton.icon(
                      icon: const Icon(Pixel.plus),
                      label: const Text("Request to be Coach"),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Request to be coach clicked!"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // ------------------- Settings -------------------
                    Text(
                      "Settings",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Theme Preferences
                    Card(
                      color: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1,
                      child: ListTile(
                        leading: const Icon(Pixel.sunalt),
                        title: const Text("Theme Preferences"),
                        onTap: () => context.read<ThemeProvider>().toggleTheme(),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Log Out
                    Card(
                      color: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1,
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
